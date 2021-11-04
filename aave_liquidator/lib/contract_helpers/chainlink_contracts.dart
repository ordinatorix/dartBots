import 'package:aave_liquidator/abi/chainlink_eth_usd_oracle.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

class ChainlinkContracts {
  late Web3Service _web3service;
  late Config _config;
  
  ChainlinkContracts(
    Web3Service web3,
    Config config,
  ) {
    _web3service = web3;
    _config = config;

    _setupContracts();
  }

  late Chainlink_eth_usd_oracle ethUsdOracleContract;
  late ContractEvent ethUsdAnswerUpdatedEvent;

  _setupContracts() {
    /// setup eth/USD price oracle contract
    ethUsdOracleContract = Chainlink_eth_usd_oracle(
      address: _config.ethUsdOracleContractAddress,
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    /// setup eth/usd events
    ethUsdAnswerUpdatedEvent = ethUsdOracleContract.self.event('AnswerUpdated');
  }
}
