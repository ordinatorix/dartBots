import 'dart:async';
import 'package:web3dart/web3dart.dart';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_eth_price_aggregator.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/chainlink_feed_registry.g.dart';
import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:aave_liquidator/token_address.dart' as token;

final log = getLogger('ChainlinkContracts');

/// sets up the chainlink contracts
///
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
  final pare = Completer<bool>();
  Future<bool> get isReady => pare.future;
  // TODO: auto fetch agregator addressand create contract on the fly

  // late Chainlink_eth_usd_oracle daiEthOracleContract;
  // late Chainlink_eth_usd_oracle maticEthOracleContract;
  // late Chainlink_eth_usd_oracle usdcEthOracleContract;
  // late Chainlink_eth_usd_oracle usdtEthOracleContract;
  // late Chainlink_eth_usd_oracle wbtcEthOracleContract;
  // late Chainlink_eth_usd_oracle wethEthOracleContract;
  // late Chainlink_eth_usd_oracle avaxEthOracleContract;
  // late Chainlink_eth_usd_oracle ethUsdOracleContract;

  late Chainlink_feed_registry feedRegistryContract;

  late Chainlink_token_eth_price_aggregator daiEthAggregator;

  late ContractEvent daiEthAnswerUpdatedEvent;

  _setupContracts() async {
    log.i('_setupContracts');
    try {
      if (_web3service.chainId == 1) {
        /// Setup Feed Registry
        feedRegistryContract = Chainlink_feed_registry(
          address: _config.feedRegistryContractAddress,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        await _setupPriceFeed();
      } else {
        // /// setup ETH/USD price oracle contract
        // ethUsdOracleProxyContract = Chainlink_eth_usd_ag_proxy(
        //   address: _config.ethUsdOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup USDT/ETH price oracle contract
        // usdtEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.usdtEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup WBTC/ETH price oracle contract
        // wbtcEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.wbtcEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup AVAX/ETH price oracle contract
        // avaxEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.avaxEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup MATIC/ETH price oracle contract
        // maticEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.maticEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup DAI/ETH price oracle contract
        // daiEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.daiEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup USDC/ETH price oracle contract
        // usdcEthOracleContract = Chainlink_eth_usd_oracle(
        //   address: _config.usdcEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );
      }
    } catch (e) {
      log.e('error setting up feed registry: $e');
    }
  }

  _setupPriceFeed() async {
    log.i('_setupPriceFeed');
// TODO: loop for all known tokens
    try {
      /// get aggregator contract address for DAI/ETH pair.
      final EthereumAddress daiEthAggregatorContractAddress =
          await feedRegistryContract.getFeed(token.daiTokenContractAddress,
              EthereumAddress.fromHex(_config.denominationEth));
      log.d(
          'DAI/Eth aggregator contract address: $daiEthAggregatorContractAddress');

      /// setup aggregator contract
      daiEthAggregator = Chainlink_token_eth_price_aggregator(
        address: daiEthAggregatorContractAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId,
      );
      // daiEthAnswerUpdatedEvent = daiEthAggregator.self.event('AnswerUpdated');
      pare.complete(true);
    } catch (e) {
      log.e('error setting up aggregator: $e');
    }
  }
}
