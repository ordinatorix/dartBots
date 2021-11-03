import 'package:aave_liquidator/abi/chainlink_eth_usd_oracle.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('ChainLinkPriceOracle');

class ChainLinkPriceOracle {
  //TODO: listen for price changes for each asset in reserve.

  late Web3Service _web3service;
  late Config _config;
  late MongodService _mongodService;
  late ContractEvent answerUpdatedEvent;
  ChainLinkPriceOracle(Web3Service web3, Config config, MongodService mongod) {
    _web3service = web3;
    _config = config;
    _mongodService = mongod;
  }

  late Chainlink_eth_usd_oracle ethUsdOracleContract;

  _setupContract() {
    ethUsdOracleContract = Chainlink_eth_usd_oracle(
      address: _config.ethUsdOracleContractAddress,
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    answerUpdatedEvent = ethUsdOracleContract.self.event('AnswerUpdated');
  }

  /// listen for eth price.
  listenForEthPriceUpdate() {
    ethUsdOracleContract.answerUpdatedEvents().listen((newPrice) {
      log.i('new price eth price');
    });
  }

  /// Listen for DAI price.
  listenForDaiPriceUpdate() {}
}
