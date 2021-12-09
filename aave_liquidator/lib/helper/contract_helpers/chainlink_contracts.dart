import 'dart:async';

import 'package:aave_liquidator/abi/chainlink_abi/aggregator_abi/chainlink_eth_denomination_price_aggregator.g.dart';
import 'package:aave_liquidator/abi/chainlink_abi/chainlink_feed_registry.g.dart';
import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';
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

  // late Chainlink_eth_usd_oracle aaveEthOracleContract;
  // late Chainlink_eth_usd_oracle batEthOracleContract;
  // late Chainlink_eth_usd_oracle busdEthOracleContract;
  // late Chainlink_eth_usd_oracle daiEthOracleContract;
  // late Chainlink_eth_usd_oracle enjEthOracleContract;
  // late Chainlink_eth_usd_oracle kncEthOracleContract;
  // late Chainlink_eth_usd_oracle linkEthOracleContract;
  // late Chainlink_eth_usd_oracle manaEthOracleContract;
  // late Chainlink_eth_usd_oracle mkrEthOracleContract;
  // late Chainlink_eth_usd_oracle renEthOracleContract;
  // late Chainlink_eth_usd_oracle snxEthOracleContract;
  // late Chainlink_eth_usd_oracle susdEthOracleContract;
  // late Chainlink_eth_usd_oracle tusdEthOracleContract;
  // late Chainlink_eth_usd_oracle usdcEthOracleContract;
  // late Chainlink_eth_usd_oracle usdtEthOracleContract;
  // late Chainlink_eth_usd_oracle wbtcEthOracleContract;
  // late Chainlink_eth_usd_oracle wethEthOracleContract;
  // late Chainlink_eth_usd_oracle yfiEthOracleContract;
  // late Chainlink_eth_usd_oracle zrxEthOracleContract;
  // late Chainlink_eth_usd_oracle uniEthOracleContract;
  // late Chainlink_eth_usd_oracle crvEthOracleContract;
  // late Chainlink_eth_usd_oracle gusdEthOracleContract;
  // late Chainlink_eth_usd_oracle balEthOracleContract;
  // late Chainlink_eth_usd_oracle xsushiEthOracleContract;
  // late Chainlink_eth_usd_oracle renFilEthOracleContract;
  // late Chainlink_eth_usd_oracle raiEthOracleContract;
  // late Chainlink_eth_usd_oracle amplEthOracleContract;
  // late Chainlink_eth_usd_oracle usdpEthOracleContract;
  // late Chainlink_eth_usd_oracle dpiEthOracleContract;
  // late Chainlink_eth_usd_oracle fraxEthOracleContract;
  // late Chainlink_eth_usd_oracle feiEthOracleContract;

  late Chainlink_feed_registry feedRegistryContract;

  late Chainlink_eth_denomination_price_aggregator daiEthAggregator;

  late ContractEvent daiEthAnswerUpdatedEvent;

  _setupContracts() async {
    log.i('_setupContracts');
    try {
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

      // /// setup YFI/ETH price oracle contract
      // yfiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.yfiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup ZRX/ETH price oracle contract
      // zrxEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.zrxEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup UNI/ETH price oracle contract
      // uniEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.uniEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup AAVE/ETH price oracle contract
      // aaveEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.aaveEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup BAT/ETH price oracle contract
      // batEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.batEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup BUSD/ETH price oracle contract
      // busdEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.busdEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup DAI/ETH price oracle contract
      // daiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.daiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup ENJ/ETH price oracle contract
      // enjEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.enjEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup KNC/ETH price oracle contract
      // kncEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.kncEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup LINK/ETH price oracle contract
      // linkEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.linkEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup MANA/ETH price oracle contract
      // manaEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.manaEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup MKR/ETH price oracle contract
      // mkrEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.mkrEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup REN/ETH price oracle contract
      // renEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.renEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup SNX/ETH price oracle contract
      // snxEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.snxEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup sUSD/ETH price oracle contract
      // susdEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.susdEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup TUSD/ETH price oracle contract
      // tusdEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.tusdEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup USDC/ETH price oracle contract
      // usdcEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.usdcEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup CRV/ETH price oracle contract
      // crvEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.crvEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup GUSD/ETH price oracle contract
      // gusdEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.gusdEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup BAL/ETH price oracle contract
      // balEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.balEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup xSUSHI/ETH price oracle contract
      // xsushiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.xsushiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup renFIL/ETH price oracle contract
      // renFilEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.renFilEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup RAI/ETH price oracle contract
      // raiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.raiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup AMPL/ETH price oracle contract
      // amplEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.amplEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup USDP/ETH price oracle contract
      // usdpEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.usdpEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup DPI/ETH price oracle contract
      // dpiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.dpiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup FRAX/ETH price oracle contract
      // fraxEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.fraxEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      // /// setup FEI/ETH price oracle contract
      // feiEthOracleContract = Chainlink_eth_usd_oracle(
      //   address: _config.feiEthOracleContractAddress,
      //   client: _web3service.web3Client,
      //   chainId: _web3service.chainId,
      // );

      /// Setup Feed Registry
      feedRegistryContract = Chainlink_feed_registry(
        address: _config.feedRegistryContractAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId,
      );
      await _setupPriceFeed();
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
      daiEthAggregator = Chainlink_eth_denomination_price_aggregator(
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
