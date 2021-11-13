import 'dart:async';

import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/contract_helpers/chainlink_contracts.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aave_liquidator/token_address.dart' as token;

final log = getLogger('ChainLinkPriceOracle');

class ChainLinkPriceOracle {
  //TODO: listen for price changes for each asset in reserve.

  late Config _config;
  late MongodService _mongodService;
  late ChainlinkContracts _chainlinkContracts;

  ChainLinkPriceOracle({
    required Config config,
    required MongodService mongod,
    required ChainlinkContracts chainlinkContracts,
  }) {
    _config = config;
    _mongodService = mongod;
    _chainlinkContracts = chainlinkContracts;
    // getEthPrice();
    getDaiPrice();
  }

  getDaiPrice() async {
    var daiPrice = await _chainlinkContracts.daiEthAggregator.latestAnswer();
    log.i('price of DAI in ETH: $daiPrice');
  }

  // getEthPrice() async {
  //   var ethPrice =
  //       await _chainlinkContracts.ethUsdOracleContract.latestAnswer();
  //   log.i('ethPrice: $ethPrice');
  // }

  priceListener() {
    log.i('priceListener');

    _listenForEthPriceUpdate();
    _listenForDaiPriceUpdate();
  }

  /// listen for eth price.
  _listenForEthPriceUpdate() {
    //TODO: price listeners
    log.i('listenForEthPriceUpdate');
  }

  /// Listen for DAI price.
  _listenForDaiPriceUpdate() {
    log.i('listenForDaiPriceUpdate');
    _chainlinkContracts.daiEthAggregator
        .answerUpdatedEvents()
        .listen((newDaiPrice) async {
      log.w('new price of dai in eth $newDaiPrice');
      String _daiTokenAddress = token.daiTokenContractAddress.toString();
      List<AaveUserAccountData> liquidatableUsers = await getTokenUser(
        tokenAddress: _daiTokenAddress,
        tokenPrice: newDaiPrice.current,
      );

      ///TODO: update price in db

      /// TODO: liquidate users
      ///
      List liquidatedUsers = liquidatableUsers
          .where((user) =>
              BigInt.parse(user.generatedHealthFactor) < BigInt.from(10000))
          .toList();

      log.w('liquidatedUsers: $liquidatedUsers');
    });
  }

  Future<List<AaveUserAccountData>> getTokenUser({
    required String tokenAddress,
    required BigInt tokenPrice,
  }) async {
    try {
      /// get previous asset reserve data from db.
      List<AaveReserveData> reserveList =
          await _mongodService.getReservesFromDb();

      /// get its previous price
      BigInt oldTokenPrice = reserveList
          .firstWhere(
            (reserve) => reserve.assetAddress == tokenAddress,
          )
          .assetPrice;
      late List<AaveUserAccountData> _userAccountDataList;

      /// if price increase,
      if (oldTokenPrice < tokenPrice) {
        /// get users with current token as debt
        _userAccountDataList = await _mongodService.getDebtUsers(tokenAddress);
      } else {
        /// if price decrease get users with dai as collateral
        _userAccountDataList =
            await _mongodService.getCollateralUsers(tokenAddress);
      }

      /// calculate healthfactor based on new price.
      ///
      /// returns list of [AaveUserAccountData] with the calculated HF
      List<AaveUserAccountData> newData = _userAccountDataList
          .map(
            (userAcount) => calculateUsersHealthFactor(
                userAccountData: userAcount,
                reserveDataList: reserveList,
                currentTokenAddress: tokenAddress,
                currentPrice: tokenPrice),
          )
          .toList();

      return newData;
    } catch (e) {
      log.e('error getting liquidatable users: $e');
      throw 'error getting liquidatable users';
    }
  }

  AaveUserAccountData calculateUsersHealthFactor({
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

  /// Calculate percent change in price from previous aave oracle price.
  getPercentChange({
    required BigInt currentPrice,
    required BigInt previousPrice,
  }) {
    log.i(
        'getPercentChange | currentPrice $currentPrice,previousPrice: $previousPrice');
  }

  /// query contract for lastest price of asset

  Future<List<BigInt>> getAllAssetsPrice(
      List<EthereumAddress> assetAddressList) async {
    log.i('getAllAssetsPrice');
    try {
      List<BigInt> assetPriceList = [];

      for (EthereumAddress address in assetAddressList) {
        final price = await _chainlinkContracts.feedRegistryContract
            .latestAnswer(
                address, EthereumAddress.fromHex(_config.denominationEth))
            .catchError((onError) {
          log.e('not found: $address');
          return Future.value(BigInt.from(-1));
        });
        log.v('price data: $price');
        assetPriceList.add(price);
      }

      return assetPriceList;
    } catch (e) {
      log.e('error getting price from oracle: $e');
      throw 'no price from oracle';
    }
  }

  // /// convert asset price to ETH
  // double convertToEth(double assetPrice) {
  //   return 10.0;
  // }
}
