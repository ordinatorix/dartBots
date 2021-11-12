import 'dart:async';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_eth_denomination_price_aggregator.g.dart';
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
      double oldDaiPrice = reserveList
          .firstWhere(
            (element) => element.assetAddress == _currentTokenAddress,
          )
          .assetPrice;
      late List<AaveUserAccountData> _userAccountDataList;

      /// if price increase,
      if (oldDaiPrice < newPrice.current.toDouble()) {
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
          currentPrice: newPrice.current.toDouble(),
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
    required double currentPrice,
  }) {
    log.i('calculateUsersHealthFactor');
    log.d('user account data list length: ${userAccountDataList.length}');
    for (AaveUserAccountData user in userAccountDataList) {
      double numeratorSum = 0;
      log.d('analizing user: ${user.userAddress}');
      var _currentReserveData = reserveDataList
          .firstWhere((element) => element.assetAddress == currentTokenAddress);
      log.d('_currentReserveData: $_currentReserveData');
      var tokenAmount = user.collateralReserve[currentTokenAddress];
      log.d('tokenAmount: $tokenAmount');
      var oldPrice = _currentReserveData.assetPrice;
      log.d('oldPrice: $oldPrice');
      var oldTokenValue = oldPrice * tokenAmount;
      log.d('oldTokenValue: $oldTokenValue');
      var newTokenValue = currentPrice * tokenAmount;
      log.d('newTokenValue: $newTokenValue');

      var totalCollat = user.totalCollateralEth - oldTokenValue + newTokenValue;
      log.d('old total collateral: ${user.totalCollateralEth}');
      log.d('totalCollat: $totalCollat');

      /// calculate the sum of each numerator
      user.collateralReserve.forEach((collateralAddress, collateralAmount) {
        var _currentReserveData = reserveDataList
            .firstWhere((element) => element.assetAddress == collateralAddress);

        /// get liquidation threshold of each asset
        double _collateralLiqThresh =
            _currentReserveData.assetConfig.liquidationThreshold;
        log.d(
            'liquidation thresh for $collateralAddress: $_collateralLiqThresh');

        double _collateralPrice = _currentReserveData.assetPrice;

        /// use the updated price when necessary
        if (collateralAddress == currentTokenAddress) {
          log.d('collateralprice: $currentPrice');
          log.d('collateral amount: $collateralAmount');
          double sumOfIt =
              currentPrice * collateralAmount * _collateralLiqThresh;
          numeratorSum = ++sumOfIt;
        } else {
          log.d('collateralprice: $_collateralPrice ');
          log.d('collateral amount: $collateralAmount');
          double sumOfIt =
              _collateralPrice * collateralAmount * _collateralLiqThresh;
          numeratorSum = ++sumOfIt;
        }

        log.d('new sum: $numeratorSum');
      });

      log.d('final sum: $numeratorSum');
      log.d('total debtEth: ${user.totalDebtETH}');
      log.w('old liqu trehs: ${user.currentLiquidationThreshold}');
      double lqtd = numeratorSum / user.totalCollateralEth;
      log.w('new liqu thresh: $lqtd');
      double hf =
          totalCollat * user.currentLiquidationThreshold / user.totalDebtETH;
      // double hf = numeratorSum / user.totalDebtETH;

      log.w('new health factor: $hf');
    }
  }

  /// Calculate percent change in price from previous aave oracle price.
  getPercentChange({
    required double currentPrice,
    required double previousPrice,
  }) {
    log.i(
        'getPercentChange | currentPrice $currentPrice,previousPrice: $previousPrice');
  }

  /// query contract for lastest price of asset

  Future<List<double>> getAllAssetsPrice(
      List<EthereumAddress> assetAddressList) async {
    log.i('getAllAssetsPrice');
    try {
      List<double> assetPriceList = [];

      for (EthereumAddress address in assetAddressList) {
        final price = await _chainlinkContracts.feedRegistryContract
            .latestAnswer(
                address, EthereumAddress.fromHex(_config.denominationEth))
            .catchError((onError) {
          log.e('not found: $address');
          return Future.value(BigInt.from(-1));
        });
        log.v('price data: $price');
        assetPriceList.add(price.toDouble());
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
