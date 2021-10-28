// import 'dart:io';

import 'package:dotenv/dotenv.dart';
// import 'package:path/path.dart';
import 'package:web3dart/web3dart.dart';

class Config {
  /// Infura api url
  final String kovanApiUrl = 'https://kovan.infura.io/v3/${env['API_KEY']}';

  /// Contract addresses
  final EthereumAddress lendingPoolProxyContractAddress =
      EthereumAddress.fromHex('0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe');

  final EthereumAddress lendingPoolContractAddress =
      EthereumAddress.fromHex('0x2646fcf7f0abb1ff279ed9845ade04019c907ebe');

  final EthereumAddress protocolDataProviderContractAddress =
      EthereumAddress.fromHex('0x3c73A5E5785cAC854D468F727c606C07488a29D6');

  /// Contract names
  // final String proxyContractName =
  //     'InitializableImmutableAdminUpgradeabilityProxy';
  // final String lendingPoolContractName = 'LendingPool';
  // final String protocolDataProviderContractName = 'AaveProtocolDataProvider';

  /// ABI file
  // final File proxyAbiFile = File(
  //     join(dirname(Platform.script.path), '../lib/abi/aave_proxy.abi.json'));
  // final File lendingPoolAbiFile = File(join(
  //     dirname(Platform.script.path), '../lib/abi/aave_lending_pool.abi.json'));
  // final File protocolDataProviderAbiFile = File(join(
  //     dirname(Platform.script.path),
  //     '../lib/abi/aave_protocol_data_provider.abi.json'));

  /// Encoded topics
  final String encodedBorrowEventTopic =
      '0xc6a898309e823ee50bac64e45ca8adba6690e99e7841c45d754e2a38e9019d9b';
  final String encodedDepositEventTopic =
      '0xde6857219544bb5b7746f48ed30be6386fefc61b2f864cacf559893bf50fd951';
  final String encodedRepayEventTopic =
      '0x4cdde6e09bb755c9a5589ebaec640bbfedff1362d4b255ebf8339782b9942faa';
  final String encodedWithdrawEventTopic =
      '0x3115d1449a7b732c986cba18244e897a450f61e1bb8d589cd2e69e6c8924f9f7';

  /// minimum health factor to take interest in. value is in wei
  final double focusHealthFactor = 1500000000000000000;

  /// Liquidators can only close a certain amount of collateral defined by a close factor.
  /// Currently the close factor is 0.5. In other words, liquidators can only liquidate a
  /// maximum of 50% of the amount pending to be repaid in a position.
  final double closeFactor = 0.5;

  /// user data storage file
  final storageFilename = 'lib/storage.json';
}

enum DeployedNetwork {
  kovan,
  mainnet,
  ropsten,
  polygon,
  avalanche,
  fantom,
  arbitrum,
  optimism,
}
