import 'dart:async';

import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/enums/deployed_networks.dart';
import 'package:aave_liquidator/helper/contract_helpers/chainlink_contracts.dart';
import 'package:aave_liquidator/helper/contract_helpers/liquidator_contract.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aave_liquidator/helper/addresses/token_address.dart' as token;

final log = getLogger('ChainLinkPriceOracle');

/// Listens for price update of assets.
///
class ChainLinkPriceOracle {
  //TODO: listen for price changes for each asset in reserve.

  late Config _config;
  late MongodService _mongodService;
  late ChainlinkContracts _chainlinkContracts;
  late LiquidatorContract _liquidatorContract;
  late DeployedNetwork _network;

  ChainLinkPriceOracle({
    required Config config,
    required MongodService mongod,
    required ChainlinkContracts chainlinkContracts,
    required LiquidatorContract liquidatorContract,
    required DeployedNetwork network,
  }) {
    _config = config;
    _mongodService = mongod;
    _chainlinkContracts = chainlinkContracts;
    _liquidatorContract = liquidatorContract;
    _network = network;
    getEthPrice();
    getDaiPrice();
  }

  getDaiPrice() async {
    var daiPrice = await _chainlinkContracts.daiEthAggregator.latestAnswer();
    log.i('price of DAI in ETH: $daiPrice');
  }

  getEthPrice() async {
    var ethPrice = await _chainlinkContracts.ethUsdAggregator.latestAnswer();
    log.i('ethPrice: $ethPrice');
  }

  priceListener() async {
    log.i('priceListener');

     _listenForEthPriceUpdate();
    await _listenForDaiPriceUpdate();
  }

  /// listen for eth price ∆.
  _listenForEthPriceUpdate() {
    //TODO: price listeners
    log.i('listenForEthPriceUpdate');
  }

  /// Listen for DAI price ∆.
  _listenForDaiPriceUpdate() async {
    log.i('listenForDaiPriceUpdate');
    String _daiTokenAddress =
        '0xff795577d9ac8bd7d90ee22b6c1703490b6512fd'; // token.daiTokenContractAddress.toString();

    /// get previous asset reserve data from db.
    List<AaveReserveData> _reserveList =
        await _mongodService.getReservesFromDb();

    /// get previous price of asset.
    BigInt _oldTokenPrice = _reserveList
        .firstWhere(
          (reserve) => reserve.assetAddress == _daiTokenAddress,
        )
        .assetPrice;

    _chainlinkContracts.daiEthAggregator
        .answerUpdatedEvents()
        .listen((newDaiPrice) async {
      log.w('new price of dai in eth $newDaiPrice');
      log.w('old price of dai in eth $_oldTokenPrice');
      // String _daiTokenAddress = token.daiTokenContractAddress.toString();
      List<AaveUserAccountData> tokenUsers = await _getTokenUser(
        tokenAddress: _daiTokenAddress,
        tokenPrice: newDaiPrice.current,
        oldTokenPrice: _oldTokenPrice,
        reserveList: _reserveList,
      );

      List<AaveUserAccountData> liquidatableUserList = tokenUsers
          .where((user) =>
              BigInt.parse(user.generatedHealthFactor) < BigInt.from(10000))
          .toList();

      log.w('liquidatedUsers: $liquidatableUserList');

      if (_oldTokenPrice < newDaiPrice.current) {
        // price increased; liquidate user with token as debt.
        log.w('Should liquidat users using Token as debt');
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
        // price decrease; liquidate user with token as collateral.
        log.w('Should liquidat users using Token as collateral');
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
      _oldTokenPrice = newDaiPrice.current;
    });
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

      /// calculate healthfactor based on new price.
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
    log.d('analizing user: ${userAccountData.userAddress}');

    /// calculate the sum of each numerator
    userAccountData.collateralReserve
        .forEach((collateralAddress, collateralAmount) {
      /// get the reserve data for each reserve user is using as collateral.
      AaveReserveData _currentReserveData = reserveDataList
          .firstWhere((element) => element.assetAddress == collateralAddress);
      BigInt decimals = _currentReserveData.assetConfig.decimals;
      BigInt factoredCollateralAmount = BigInt.parse(collateralAmount);

      if (decimals < BigInt.from(18)) {
        log.d('raw collateralAmount: $collateralAmount');
        int xFactor = 18 - decimals.toInt();
        factoredCollateralAmount =
            BigInt.parse(collateralAmount) * BigInt.from(10).pow(xFactor);
        log.d('factored collateral amount: $factoredCollateralAmount');
      } else {
        // log.w(decimals);
      }

      /// get liquidation threshold of each asset
      BigInt _collateralLiqThresh =
          _currentReserveData.assetConfig.liquidationThreshold;
      log.d(
          'liquidation thresh for $collateralAddress: $_collateralLiqThresh'); // * BigInt.from(10000)}');

      /// use the updated price when necessary
      if (collateralAddress == currentTokenAddress) {
        log.d('collateral price for $collateralAddress: $currentPrice');
        log.d(
            'collateral amount for $collateralAddress: $factoredCollateralAmount;');

        BigInt tokenVal = factoredCollateralAmount * currentPrice;
        log.d('collateral value Eth for $collateralAddress: $tokenVal');

        calculatedCollateralETH = calculatedCollateralETH + tokenVal;

        BigInt sumOfIt = tokenVal * _collateralLiqThresh; //* BigInt.from(0.01);
        numeratorSum = numeratorSum + sumOfIt;
      } else {
        /// get asset price
        BigInt _collateralPrice = _currentReserveData.assetPrice;

        log.d('collateral price for $collateralAddress: $_collateralPrice');
        log.d(
            'collateral amount for $collateralAddress: $factoredCollateralAmount');
        BigInt tokenVal = factoredCollateralAmount * _collateralPrice;
        log.d('collateral value Eth for $collateralAddress: $tokenVal');
        calculatedCollateralETH = calculatedCollateralETH + tokenVal;
        BigInt sumOfIt = tokenVal * _collateralLiqThresh; //* BigInt.from(0.01);
        numeratorSum = numeratorSum + sumOfIt;
      }
    });

    log.d(
        'calc total collateral ETH: ${calculatedCollateralETH / BigInt.from(10).pow(18)}');
    log.d('total collateral ETH: ${userAccountData.totalCollateralEth}');
    log.d('total debtEth: ${userAccountData.totalDebtETH}');
    log.d('old liqu trehs: ${userAccountData.currentLiquidationThreshold}');
    BigInt lqtd = BigInt.from(numeratorSum / calculatedCollateralETH);

    log.d('new liqu thresh: $lqtd');

    BigInt hf = BigInt.from(
        BigInt.from(numeratorSum / userAccountData.totalDebtETH) /
            BigInt.from(10).pow(18));
    log.w('old health factor: ${userAccountData.healthFactor}');
    log.w('new health factor: $hf');
    AaveUserAccountData calculatedUserData = userAccountData;
    calculatedUserData.generatedHealthFactor = hf.toString();
    return calculatedUserData;
  }

  /// Query contract for lastest price of asset in list.
  Future<List<BigInt>> getAllAssetsPrice(
      List<EthereumAddress> assetAddressList) async {
    log.i('getAllAssetsPrice');
    try {
      List<BigInt> assetPriceList = [];

      for (EthereumAddress address in assetAddressList) {
        if (_network.index == 2) {
          final price = await _chainlinkContracts.feedRegistryContract
              .latestAnswer(
                  address, EthereumAddress.fromHex(_config.denominationEth))
              .catchError((onError) {
            log.e('not found: $address');
            return Future.value(BigInt.from(-1));
          });
          log.v('price data: $price');
          assetPriceList.add(price);
        } else {
          assetPriceList.add(BigInt.from(-1));
        }
      }

      return assetPriceList;
    } catch (e) {
      log.e('error getting price from oracle: $e');
      throw 'no price from oracle';
    }
  }
}
