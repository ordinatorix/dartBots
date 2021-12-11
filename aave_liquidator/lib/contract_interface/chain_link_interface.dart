import 'dart:async';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_eth_price_aggregator.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_usd_price_aggregator.g.dart';
import 'package:aave_liquidator/configs/config.dart';

import 'package:aave_liquidator/enums/deployed_networks.dart';
import 'package:aave_liquidator/helper/contract_helpers/chainlink_contracts.dart';
import 'package:aave_liquidator/helper/contract_helpers/liquidator_contract.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('ChainLinkPriceOracle');

/// Listens for price update of assets.
///
class ChainLinkPriceOracle {
  late Config _config;
  late MongodService _mongodService;
  late ChainlinkContracts _chainlinkContracts;
  late LiquidatorContract _liquidatorContract;
  late DeployedNetwork _network;
  late Web3Service _web3service;

  ChainLinkPriceOracle({
    required Config config,
    required MongodService mongod,
    required LiquidatorContract liquidatorContract,
    required DeployedNetwork network,
    required Web3Service web3,
  }) {
    _config = config;
    _mongodService = mongod;
    _web3service = web3;
    _chainlinkContracts = ChainlinkContracts(
      _web3service,
      _config,
    );

    _liquidatorContract = liquidatorContract;
    _network = network;
  }
  late List<AaveReserveData> _reserveList;
  // getDaiPrice() async {
  //   log.i('getDaiPrice');
  //   await _chainlinkContracts.isReady;
  //   var daiPrice = await _chainlinkContracts.daiEthAggregator.latestAnswer();
  //   log.i('price of DAI in ETH: $daiPrice');
  // }

  // getEthPrice() async {
  //   log.i('getEthPrice');
  //   await _chainlinkContracts.isReady;
  //   var ethPrice = await _chainlinkContracts.ethUsdAggregator.latestAnswer();
  //   log.i('ethPrice: $ethPrice');
  // }

  priceListener() async {
    log.i('priceListener');
    try {
      /// get list of tokens known to us.
      _reserveList = await _mongodService.getReservesFromDb();

      /// wait for chainlink contracts to be ready.
      log.v('Waiting on chainlink contract setup');
      await _chainlinkContracts.isReady;

      /// Iterate through all known assets.
      for (var asset in _reserveList) {
        /// if connected to mainnet
        if (_network == DeployedNetwork.mainnet) {
          /// Start listening for token price update.
          await _listenForPriceUpdate(
            tokenData: asset,
          );
        } else {
          switch (asset.assetSymbol) {
            case 'WETH':
              await _listenForEthPriceUpdate(
                tokenData: asset,
              );
              break;
            default:
              if (_config.aggregatorAddress
                  .containsKey('${asset.assetSymbol}/ETH')) {
                /// Start listening for DAI price update.
                await _listenForPriceUpdate(
                    tokenData: asset,
                    aggregatorProxyAddress:
                        _config.aggregatorAddress['${asset.assetSymbol}/ETH']!);
              } else {
                log.w(
                    'not listenning to ${asset.assetSymbol}. aggregator address not available.');
              }
          }
        }
      }
    } catch (e) {
      log.e('error listening to prices');
    }
  }

  /// listen for ETH price ∆.
  _listenForEthPriceUpdate({
    required AaveReserveData tokenData,
  }) async {
    log.i('listenForEthPriceUpdate | tokenData: $tokenData');
    try {
      late Chainlink_token_usd_price_aggregator _tokenAggregator;

      /// get previous price of asset.
      BigInt _oldEthPrice = tokenData.assetPrice;
      if (_config.aggregatorAddress
          .containsKey('${tokenData.assetSymbol}/USD')) {
        /// Setup price aggregator via proxy contract
        _tokenAggregator =
            await _chainlinkContracts.setupEthUsdAggregatorViaProxy(
                aggregatorProxyAddress:
                    _config.aggregatorAddress['${tokenData.assetSymbol}/USD']!);

        _tokenAggregator.answerUpdatedEvents().listen((newPrice) async {
          await _onPriceUpdate(
            tokenData: tokenData,
            newPrice: newPrice.current,
            lastPrice: _oldEthPrice,
          );

          _oldEthPrice = newPrice.current;
        });
      } else {
        throw 'Aggregator address not set.';
      }
    } catch (e) {
      log.e('error listening for eth price updates');
    }
  }

  /// Listen for asset price ∆.
  ///
  /// [aggregatorProxyAddress] is optional. If ommited, the feedRegistry is used to get the price.
  ///
  /// NOTE: Feed registry is currently only available on Mainnet.
  _listenForPriceUpdate({
    required AaveReserveData tokenData,
    EthereumAddress? aggregatorProxyAddress,
  }) async {
    log.i(
        'listenForPriceUpdate | tokenData: $tokenData; aggregatorProxyAddress: $aggregatorProxyAddress');
    try {
      late Chainlink_token_eth_price_aggregator _tokenAggregator;

      /// get previous price of asset.
      BigInt _oldTokenPrice = tokenData.assetPrice;

      if (aggregatorProxyAddress != null) {
        /// Setup price aggregator via proxy contract
        _tokenAggregator = await _chainlinkContracts.setupAggregatorViaProxy(
          aggregatorProxyAddress: aggregatorProxyAddress,
        );
      } else {
        _tokenAggregator = await _chainlinkContracts.setupPriceFeed(
          tokenData: tokenData,
          denomination: EthereumAddress.fromHex(_config.denominationEth),
        );
      }

      _tokenAggregator.answerUpdatedEvents().listen((newPrice) async {
        await _onPriceUpdate(
          tokenData: tokenData,
          newPrice: newPrice.current,
          lastPrice: _oldTokenPrice,
        );
        _oldTokenPrice = newPrice.current;
      });
    } catch (e) {
      log.e(
          'error while listening to ${tokenData.assetSymbol} price updates: $e');
    }
  }

  _onPriceUpdate({
    required AaveReserveData tokenData,
    required BigInt newPrice,
    required BigInt lastPrice,
  }) async {
    log.w('old price of ${tokenData.assetSymbol} in eth $lastPrice');
    log.w('new price of ${tokenData.assetSymbol} in eth $newPrice');

    List<AaveUserAccountData> tokenUsers = await _getTokenUser(
      tokenAddress: tokenData.assetAddress,
      tokenPrice: newPrice,
      oldTokenPrice: lastPrice,
      reserveList: _reserveList,
    );

    List<AaveUserAccountData> liquidatableUserList = tokenUsers
        .where((user) =>
            BigInt.parse(user.generatedHealthFactor) < BigInt.from(10000))
        .toList();

    log.w('liquidatable Users: $liquidatableUserList');

    if (lastPrice < newPrice) {
      log.v('price increased');
      // price increased; liquidate user with token as debt.
      log.w('Should liquidate users using Token as debt');
      // for (AaveUserAccountData liquidatableUser in liquidatableUserList) {
      //   await _liquidatorContract.liquidateAaveUser(
      //     collateralAsset: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
      //     debtAsset: _daiTokenAddress,
      //     user: liquidatableUser.userAddress,
      //     debtToCover: liquidatableUser.variableDebtReserve[_daiTokenAddress],
      //     useEthPath: false,
      //   );
      // }
    } else {
      log.v('price decreased');
      // price decrease; liquidate user with token as collateral.
      log.w('Should liquidate users using Token as collateral');
      // for (AaveUserAccountData liquidatableUser in liquidatableUserList) {
      //   await _liquidatorContract.liquidateAaveUser(
      //     collateralAsset: _daiTokenAddress,
      //     debtAsset: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
      //     user: liquidatableUser.userAddress,
      //     debtToCover: liquidatableUser.variableDebtReserve[
      //         '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'],
      //     useEthPath: false,
      //   );
      // }
    }

    ///TODO: update price in db
    ///
  }

  /// Get list of users using specific Token.
  ///
  /// Returns list of user account holding token as either debt or collateral.
  Future<List<AaveUserAccountData>> _getTokenUser({
    required String tokenAddress,
    required BigInt tokenPrice,
    required BigInt oldTokenPrice,
    required List<AaveReserveData> reserveList,
  }) async {
    log.i(
        'getTokenUser | tokenAddress: $tokenAddress; tokenPrice: $tokenPrice');
    try {
      late List<AaveUserAccountData> _userAccountDataList;

      /// get users depending on price change direction.
      if (oldTokenPrice < tokenPrice) {
        /// get users with current token as debt
        _userAccountDataList = await _mongodService.getDebtUsers(tokenAddress);
      } else {
        /// get users with dai as collateral.
        _userAccountDataList =
            await _mongodService.getCollateralUsers(tokenAddress);
      }

      /// Calculate healthfactor based on new price.
      ///
      /// returns list of [AaveUserAccountData] with the calculated HF
      List<AaveUserAccountData> newData = _userAccountDataList
          .map(
            (userAcount) => _calculateUsersHealthFactor(
                userAccountData: userAcount,
                reserveDataList: reserveList,
                currentTokenAddress: tokenAddress,
                currentPrice: tokenPrice),
          )
          .toList();

      return newData;
    } catch (e) {
      log.e('error getting token users: $e');
      throw 'error getting token users';
    }
  }

  /// Calculate user health factor using new price.
  ///
  /// The formula used can be found => https://docs.aave.com/risk/asset-risk/risk-parameters#health-factor
  AaveUserAccountData _calculateUsersHealthFactor({
    required AaveUserAccountData userAccountData,
    required List<AaveReserveData> reserveDataList,
    required String currentTokenAddress,
    required BigInt currentPrice,
  }) {
    log.i(
        'calculateUsersHealthFactor | userAddress: ${userAccountData.userAddress}');

    BigInt numeratorSum = BigInt.zero;

    BigInt calculatedCollateralETH = BigInt.zero;

    /// calculate the sum of each numerator
    userAccountData.collateralReserve
        .forEach((collateralAddress, collateralAmount) {
      /// get the reserve data for each reserve user is using as collateral.
      AaveReserveData _currentReserveData = reserveDataList
          .firstWhere((element) => element.assetAddress == collateralAddress);
      BigInt decimals = _currentReserveData.assetConfig.decimals;
      BigInt factoredCollateralAmount = BigInt.parse(collateralAmount);

      /// account for tokens with smaller decimal values.
      if (decimals < BigInt.from(18)) {
        int xFactor = 18 - decimals.toInt();
        factoredCollateralAmount =
            BigInt.parse(collateralAmount) * BigInt.from(10).pow(xFactor);
      }

      /// get liquidation threshold of each asset
      BigInt _collateralLiqThresh =
          _currentReserveData.assetConfig.liquidationThreshold;

      /// use the updated price on the asset that triggered a price change.
      if (collateralAddress == currentTokenAddress) {
        log.d('collateral price for $collateralAddress: $currentPrice');
        log.d(
            'collateral amount for $collateralAddress: $factoredCollateralAmount;');

        BigInt tokenVal = factoredCollateralAmount * currentPrice;

        calculatedCollateralETH = calculatedCollateralETH + tokenVal;

        BigInt sumOfIt = tokenVal * _collateralLiqThresh; //* BigInt.from(0.01);
        numeratorSum = numeratorSum + sumOfIt;
      } else {
        /// otherwise use the known price.
        BigInt _collateralPrice = _currentReserveData.assetPrice;

        BigInt tokenVal = factoredCollateralAmount * _collateralPrice;

        calculatedCollateralETH = calculatedCollateralETH + tokenVal;
        BigInt sumOfIt = tokenVal * _collateralLiqThresh; //* BigInt.from(0.01);
        numeratorSum = numeratorSum + sumOfIt;
      }
    });

    BigInt updatedLiquidationTreshold =
        BigInt.from(numeratorSum / calculatedCollateralETH);

    BigInt updatedHealthFactor = BigInt.from(
      BigInt.from(numeratorSum / userAccountData.totalDebtETH) /
          BigInt.from(10).pow(18),
    );

    AaveUserAccountData calculatedUserData = userAccountData;
    calculatedUserData.generatedHealthFactor = updatedHealthFactor.toString();
    log.v('Calculated User Data: $calculatedUserData');
    return calculatedUserData;
  }

  /// Query contract for lastest price of asset in list.
  Future<List<BigInt>> getAllAssetsPrice(
      List<EthereumAddress> assetAddressList) async {
    log.i('getAllAssetsPrice | assetAddressList: $assetAddressList');
    try {
      List<BigInt> assetPriceList = [];

      ///iterate through all assets
      for (EthereumAddress address in assetAddressList) {
        if (_network == DeployedNetwork.mainnet) {
          // use the feed registry.
          late BigInt price;
          switch (address.toString()) {
            case '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599': // WBTC case
              price = await _chainlinkContracts.feedRegistryContract
                  .latestAnswer(
                      EthereumAddress.fromHex(_config.denominationBtc),
                      EthereumAddress.fromHex(_config.denominationEth))
                  .catchError((onError) {
                log.e('not found: $address');
                return Future.value(BigInt.from(-1));
              });
              break;
            case '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2': //WETH case
              price = await _chainlinkContracts.feedRegistryContract
                  .latestAnswer(
                      EthereumAddress.fromHex(_config.denominationEth),
                      EthereumAddress.fromHex(_config.denominationUSD))
                  .catchError((onError) {
                log.e('not found: $address');
                return Future.value(BigInt.from(-1));
              });
              break;
            default:
              price = await _chainlinkContracts.feedRegistryContract
                  .latestAnswer(
                      address, EthereumAddress.fromHex(_config.denominationEth))
                  .catchError((onError) {
                log.e('not found: $address');
                return Future.value(BigInt.from(-1));
              });
          }

          log.v('$address price: $price');
          assetPriceList.add(price);
        } else {
          /// add -1 to the list, so that we know to use aaves price oracle.
          assetPriceList.add(BigInt.from(-1));
        }
      }

      return assetPriceList;
    } catch (e) {
      log.e('error getting price from oracle: $e');
      throw 'no price received from oracle';
    }
  }
}
