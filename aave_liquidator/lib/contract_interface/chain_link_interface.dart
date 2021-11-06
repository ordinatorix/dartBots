import 'dart:async';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_eth_denomination_price_aggregator.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/contract_helpers/chainlink_contracts.dart';
import 'package:aave_liquidator/logger.dart';
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
    log.i('listenning for price update');

    _chainlinkContracts.daiEthAggregator.answerUpdatedEvents().listen((event) {
      log.w('new dai price in eth: ${event.current}');
    });
  }

  /// listen for eth price.
  StreamSubscription<AnswerUpdated> listenForEthPriceUpdate() {
    log.i('listenForEthPriceUpdate');

    return _chainlinkContracts.daiEthAggregator
        .answerUpdatedEvents()
        .listen((newPrice) {
      log.w('new price of dai in eth $newPrice');
      double _currentPrice = newPrice.current.toDouble();
      double _previousPrice = 1; //TODO: get pricefrom db.
      getPercentChange(
        currentPrice: _currentPrice,
        previousPrice: _previousPrice,
      );
      // update asset price in db
      // _mongodService.updateReserveAssetPrice(
      //     assetAddress: '_config.ethTokenAddress',
      //     newAssetPrice: _currentPrice);
    });
  }

  /// Listen for DAI price.
  listenForDaiPriceUpdate() {}

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
