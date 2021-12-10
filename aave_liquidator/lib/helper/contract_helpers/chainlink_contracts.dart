import 'dart:async';
import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_aggregator_proxy.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_usd_price_aggregator.g.dart';

import 'package:web3dart/web3dart.dart';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_eth_price_aggregator.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/chainlink_feed_registry.g.dart';
import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:aave_liquidator/helper/addresses/token_address.dart' as token;

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

  late Chainlink_aggregator_proxy daiEthOracleProxyContract;
  late Chainlink_aggregator_proxy usdcEthOracleProxyContract;
  late Chainlink_aggregator_proxy usdtEthOracleProxyContract;
  late Chainlink_aggregator_proxy wbtcEthOracleProxyContract;
  late Chainlink_aggregator_proxy wethEthOracleProxyContract;
  late Chainlink_aggregator_proxy ethUsdOracleProxyContract;
  // late Chainlink_agregator_proxy avaxEthOracleProxyContract;
  // late Chainlink_agregator_proxy maticEthOracleProxyContract;

  late Chainlink_feed_registry feedRegistryContract;

  late Chainlink_token_eth_price_aggregator daiEthAggregator;
  late Chainlink_token_eth_price_aggregator usdcEthAggregator;
  late Chainlink_token_eth_price_aggregator usdtEthAggregator;
  late Chainlink_token_eth_price_aggregator wbtcEthAggregator;
  late Chainlink_token_eth_price_aggregator maticEthAggregator;
  late Chainlink_token_eth_price_aggregator avaxEthAggregator;
  late Chainlink_token_usd_price_aggregator ethUsdAggregator;

  // late ContractEvent daiEthAnswerUpdatedEvent;

  _setupContracts() async {
    log.i('_setupContracts');
    try {
      if (_web3service.chainId == 1) {
        /// Setup Feed Registry
        log.d('setting up mainnet price feed registry');
        feedRegistryContract = Chainlink_feed_registry(
          address: _config.feedRegistryContractAddress,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        await _setupPriceFeed();
      } else {
        log.d('setting up kovan price aggregators proxy');

        /// setup DAI/ETH price oracle contract
        daiEthOracleProxyContract = Chainlink_aggregator_proxy(
          address: _config.aggregatorAddress["DAI/ETH"]!,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        /// setup USDT/ETH price oracle contract
        usdtEthOracleProxyContract = Chainlink_aggregator_proxy(
          address: _config.aggregatorAddress["USDT/ETH"]!,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        /// setup WBTC/ETH price oracle contract
        wbtcEthOracleProxyContract = Chainlink_aggregator_proxy(
          address: _config.aggregatorAddress["WBTC/ETH"]!,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        /// setup USDC/ETH price oracle contract
        usdcEthOracleProxyContract = Chainlink_aggregator_proxy(
          address: _config.aggregatorAddress["USDC/ETH"]!,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        /// setup ETH/USD price oracle contract
        ethUsdOracleProxyContract = Chainlink_aggregator_proxy(
          address: _config.aggregatorAddress["ETH/USD"]!,
          client: _web3service.web3Client,
          chainId: _web3service.chainId,
        );

        // /// setup AVAX/ETH price oracle contract
        // avaxEthOracleProxyContract = Chainlink_aggregator_proxy(
        //   address: _config.avaxEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );

        // /// setup MATIC/ETH price oracle contract
        // maticEthOracleProxyContract = Chainlink_aggregator_proxy(
        //   address: _config.maticEthOracleContractAddress,
        //   client: _web3service.web3Client,
        //   chainId: _web3service.chainId,
        // );
        await _setupAggregretors();
        pare.complete(true);
      }
    } catch (e) {
      log.e('error setting up feed registry: $e');
    }
  }

  _setupAggregretors() async {
    log.i('_setupAggregretors');

    /// setup DAI/ETH price oracle contract
    daiEthAggregator = Chainlink_token_eth_price_aggregator(
      address: await daiEthOracleProxyContract.aggregator(),
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    /// setup USDT/ETH price oracle contract
    usdtEthAggregator = Chainlink_token_eth_price_aggregator(
      address: await usdtEthOracleProxyContract.aggregator(),
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    /// setup WBTC/ETH price oracle contract
    wbtcEthAggregator = Chainlink_token_eth_price_aggregator(
      address: await wbtcEthOracleProxyContract.aggregator(),
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    /// setup USDC/ETH price oracle contract
    usdcEthAggregator = Chainlink_token_eth_price_aggregator(
      address: await usdcEthOracleProxyContract.aggregator(),
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    /// setup ETH/USD price oracle contract
    ethUsdAggregator = Chainlink_token_usd_price_aggregator(
      address: await ethUsdOracleProxyContract.aggregator(),
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );

    // /// setup AVAX/ETH price oracle contract
    // avaxEthOracleProxyContract = Chainlink_token_eth_price_aggregator(
    //   address: _config.avaxEthOracleContractAddress,
    //   client: _web3service.web3Client,
    //   chainId: _web3service.chainId,
    // );

    // /// setup MATIC/ETH price oracle contract
    // maticEthOracleProxyContract = Chainlink_token_eth_price_aggregator(
    //   address: _config.maticEthOracleContractAddress,
    //   client: _web3service.web3Client,
    //   chainId: _web3service.chainId,
    // );
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
