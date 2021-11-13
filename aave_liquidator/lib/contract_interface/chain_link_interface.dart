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
        .listen((newPrice) async {
      String _currentTokenAddress = token.daiTokenContractAddress.toString();

      /// get previous asset reserve data from db.
      List<AaveReserveData> reserveList =
          await _mongodService.getReservesFromDb();

      /// get its previous price
      BigInt oldDaiPrice = reserveList
          .firstWhere(
            (element) => element.assetAddress == _currentTokenAddress,
          )
          .assetPrice;
      late List<AaveUserAccountData> _userAccountDataList;

      /// if price increase,
      if (oldDaiPrice < newPrice.current) {
        /// get users with current token as debt
        _userAccountDataList =
            await _mongodService.getDebtUsers(_currentTokenAddress);
      } else {
        /// if price decrease get users with dai as collateral
        _userAccountDataList =
            await _mongodService.getCollateralUsers(_currentTokenAddress);
      }

      log.w('new price of dai in eth $newPrice');

      /// calculate health factor of each user in [_userAccountDataList].
      ///
      /// hf = total collateralEth * liquidation thresh
      ///      ---------------------------------------
      ///                total borrow

      calculateUsersHealthFactor(
          currentPrice: newPrice.current,
          currentTokenAddress: _currentTokenAddress,
          reserveDataList: reserveList,
          userAccountDataList: _userAccountDataList);

      ///TODO: update price in db

      /// TODO: liquidate users
    });
  }

  calculateUsersHealthFactor({
    required List<AaveUserAccountData> userAccountDataList,
    required List<AaveReserveData> reserveDataList,
    required String currentTokenAddress,
    required BigInt currentPrice,
  }) {
    log.i('calculateUsersHealthFactor');
    log.d('user account data list length: ${userAccountDataList.length}');
    for (AaveUserAccountData user in userAccountDataList) {
      BigInt numeratorSum = BigInt.zero;

      BigInt calculatedCollateralETH = BigInt.zero;
      log.d('analizing user: ${user.userAddress}');

      ///get all reserves user uses
      // AaveReserveData _currentReserveData = reserveDataList
      //     .firstWhere((element) => element.assetAddress == currentTokenAddress);
      // log.d('_currentReserveData: $_currentReserveData');
      // log.d('current Price: $currentPrice');
      // BigInt tokenAmount =
      //     BigInt.parse(user.collateralReserve[currentTokenAddress]);
      // log.d('tokenAmount: $tokenAmount');
      // BigInt oldPrice = _currentReserveData.assetPrice;
      // log.d('oldPrice: $oldPrice');
      // BigInt oldTokenValue = oldPrice * tokenAmount;
      // log.d('oldTokenValueETH: $oldTokenValue');
      // BigInt newTokenValue = currentPrice * tokenAmount;
      // log.d('newTokenValueETH: $newTokenValue');

      // BigInt totalCollat =
      //     user.totalCollateralEth - oldTokenValue + newTokenValue;
      // log.d('old total collateral: ${user.totalCollateralEth}');
      // log.d('new total Collateral: $totalCollat');

      /// calculate the sum of each numerator
      user.collateralReserve.forEach((collateralAddress, collateralAmount) {
        /// get the reserve data for each reserve user is using as collateral.
        AaveReserveData _currentReserveData = reserveDataList
            .firstWhere((element) => element.assetAddress == collateralAddress);
        BigInt decimals = _currentReserveData.assetConfig.decimals;
        BigInt factoredCollateralAmount = BigInt.parse(collateralAmount);

        if (decimals < BigInt.from(18)) {
          log.w('raw collateralAmount: $collateralAmount');
          int xFactor = 18 - decimals.toInt();
          factoredCollateralAmount =
              BigInt.parse(collateralAmount) * BigInt.from(10).pow(xFactor);
          log.d('factored collateral amount: $factoredCollateralAmount');
        } else {
          log.w(decimals);
        }

        /// get liquidation threshold of each asset
        BigInt _collateralLiqThresh =
            _currentReserveData.assetConfig.liquidationThreshold;
        log.d(
            'liquidation thresh for $collateralAddress: $_collateralLiqThresh');// * BigInt.from(10000)}');

        /// use the updated price when necessary
        if (collateralAddress == currentTokenAddress) {
          log.d('collateral price for $collateralAddress: $currentPrice');
          log.d(
              'collateral amount for $collateralAddress: $factoredCollateralAmount;');

          BigInt tokenVal = factoredCollateralAmount * currentPrice;
          log.d('collateral value Eth for $collateralAddress: $tokenVal');

          calculatedCollateralETH = calculatedCollateralETH + tokenVal;

          BigInt sumOfIt = tokenVal * _collateralLiqThresh ;//* BigInt.from(0.01);
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
          BigInt sumOfIt = tokenVal * _collateralLiqThresh ;//* BigInt.from(0.01);
          numeratorSum = numeratorSum + sumOfIt;
        }

        // log.d('new sum: $numeratorSum');
      });
      // log.d('Collateral Amount: $calcTotCol');
      log.d(
          'calc total collateral ETH: ${calculatedCollateralETH / BigInt.from(10).pow(18)}');
      log.d('total collateral ETH: ${user.totalCollateralEth}');
      log.d('total debtEth: ${user.totalDebtETH}');
      log.w('old liqu trehs: ${user.currentLiquidationThreshold}');
      BigInt lqtd = BigInt.from(numeratorSum / calculatedCollateralETH);
      // BigInt lqtd = BigInt.from(
      //     (calculatedCollateralETH * user.currentLiquidationThreshold) /
      //         user.totalCollateralEth);
      log.w('new liqu thresh: $lqtd');
      // BigInt hf = BigInt.from(
      //     (calculatedCollateralETH * user.currentLiquidationThreshold) /
      //         user.totalDebtETH);
      BigInt hf = BigInt.from(numeratorSum / user.totalDebtETH);
      log.w('old health factor: ${user.healthFactor}');
      log.w('new health factor: $hf');
    }
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
