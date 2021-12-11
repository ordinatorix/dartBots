import 'dart:async';
import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_aggregator_proxy.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_usd_price_aggregator.g.dart';
import 'package:aave_liquidator/contract_interface/chain_link_interface.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';

import 'package:web3dart/web3dart.dart';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_token_eth_price_aggregator.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/chainlink_feed_registry.g.dart';
import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/web3_service.dart';

final log = getLogger('ChainlinkContracts');

/// Sets up the chainlink contracts
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
  late ChainLinkPriceOracle priceOracleInterface;
  final pare = Completer<bool>();
  Future<bool> get isReady => pare.future;

  late Chainlink_aggregator_proxy tokenAggregatorProxyContract;

  late Chainlink_feed_registry feedRegistryContract;

  late Chainlink_token_eth_price_aggregator tokenEthAggregator;
  late Chainlink_token_usd_price_aggregator tokenUsdAggregator;

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
      } else {
        log.d('setting up price aggregator proxys');
      }
      pare.complete(true);
    } catch (e) {
      log.e('error setting up feed registry: $e');
    }
  }

  /// setup token/ETH aggregator using aggregator contract address.
  Chainlink_token_eth_price_aggregator _setupAggregator(
      {required EthereumAddress aggregatorAddress}) {
    /// setup token/ETH price oracle contract
    return tokenEthAggregator = Chainlink_token_eth_price_aggregator(
      address: aggregatorAddress,
      client: _web3service.web3Client,
      chainId: _web3service.chainId,
    );
  }

  /// Setup token/USD aggregator using aggregator proxy contract address.
  ///
  /// Returns a chainlink price aggregator interface for the specified token.
  Future<Chainlink_token_usd_price_aggregator> setupEthUsdAggregatorViaProxy(
      {required EthereumAddress aggregatorProxyAddress}) async {
    try {
      /// setup token/ETH price oracle contract
      tokenAggregatorProxyContract = Chainlink_aggregator_proxy(
        address: aggregatorProxyAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId,
      );
      final EthereumAddress _aggregatorAddress =
          await tokenAggregatorProxyContract.aggregator();

      return tokenUsdAggregator = Chainlink_token_usd_price_aggregator(
        address: _aggregatorAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId,
      );
    } catch (e) {
      log.e('error setting up aggregator using proxy address: $e');
      throw 'error setting up aggregator using proxy address';
    }
  }

  /// Setup token/ETH aggregator using aggregator proxy contract address.
  ///
  /// Returns a chainlink price aggregatorinterface for the specified token.
  Future<Chainlink_token_eth_price_aggregator> setupAggregatorViaProxy(
      {required EthereumAddress aggregatorProxyAddress}) async {
    try {
      /// setup token/ETH price oracle contract
      tokenAggregatorProxyContract = Chainlink_aggregator_proxy(
        address: aggregatorProxyAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId,
      );
      final EthereumAddress _aggregatorAddress =
          await tokenAggregatorProxyContract.aggregator();

      return _setupAggregator(aggregatorAddress: _aggregatorAddress);
    } catch (e) {
      log.e('error setting up aggregator using proxy address: $e');
      throw 'error setting up aggregator using proxy address';
    }
  }

  Future<Chainlink_token_eth_price_aggregator> setupPriceFeed({
    required AaveReserveData tokenData,
    required EthereumAddress denomination,
  }) async {
    log.i(
        '_setupPriceFeed | tokenData: $tokenData, denomination: $denomination');

    try {
      late EthereumAddress tokenDenominatorAggregatorContractAddress;

      /// get aggregator contract address for token pair.
      switch (tokenData.assetSymbol) {
        case 'WBTC':
          tokenDenominatorAggregatorContractAddress =
              await feedRegistryContract.getFeed(
            EthereumAddress.fromHex(_config.denominationBtc),
            denomination,
          );

          break;
        case 'WETH':
          tokenDenominatorAggregatorContractAddress =
              await feedRegistryContract.getFeed(
            EthereumAddress.fromHex(_config.denominationEth),
            EthereumAddress.fromHex(_config.denominationUSD),
          );

          break;
        default:
          tokenDenominatorAggregatorContractAddress =
              await feedRegistryContract.getFeed(
            EthereumAddress.fromHex(tokenData.assetAddress),
            denomination,
          );
      }

      final _tokenAggregator = _setupAggregator(
          aggregatorAddress: tokenDenominatorAggregatorContractAddress);
      return _tokenAggregator;
    } catch (e) {
      log.e('Error setting up aggregator: $e');
      throw 'Error with price feed setup';
    }
  }
}
