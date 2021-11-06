// import 'dart:io';
import 'package:aave_liquidator/token_address.dart';
import 'package:dotenv/dotenv.dart';
// import 'package:path/path.dart';
import 'package:web3dart/web3dart.dart';

class Config {
  /// Infura api url
  final String kovanApiUrl = 'https://kovan.infura.io/v3/${env['API_KEY']}';
  final String mainnetApiUrl = 'https://mainnet.infura.io/v3/${env['API_KEY']}';

  /// Aave Mainnet Contract addresses
  /// TODO: group address by network
  ///
  final EthereumAddress lendingPoolProxyContractAddress =
      EthereumAddress.fromHex('0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9'); //

  final EthereumAddress lendingPoolContractAddress =
      EthereumAddress.fromHex('0xC6845a5C768BF8D7681249f8927877Efda425baf'); //

  final EthereumAddress protocolDataProviderContractAddress =
      EthereumAddress.fromHex('0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d'); //

  final EthereumAddress aavePriceOracleContractAddress =
      EthereumAddress.fromHex('0xA50ba011c48153De246E5192C8f9258A2ba79Ca9'); //

  /// Aave Kovan contract address
  // final EthereumAddress lendingPoolProxyContractAddress =
  //     EthereumAddress.fromHex('0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe');

  // final EthereumAddress lendingPoolContractAddress =
  //     EthereumAddress.fromHex('0x2646fcf7f0abb1ff279ed9845ade04019c907ebe');

  // final EthereumAddress protocolDataProviderContractAddress =
  //     EthereumAddress.fromHex('0x3c73A5E5785cAC854D468F727c606C07488a29D6');

  // final EthereumAddress aavePriceOracleContractAddress =
  //     EthereumAddress.fromHex('0xB8bE51E6563BB312Cbb2aa26e352516c25c26ac1');

  /// Chainlink Mainnet contract addresses
  ///

  final EthereumAddress feedRegistryContractAddress =
      EthereumAddress.fromHex('0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf');

  // final EthereumAddress ethUsdOracleContractAddressProxy =
  //     EthereumAddress.fromHex('0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419');

  // final EthereumAddress ethUsdOracleContractAddress =
  //     EthereumAddress.fromHex('0x37bC7498f4FF12C19678ee8fE19d713b87F6a9e6');

  // final EthereumAddress aaveEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress usdtEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress wbtcEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress yfiEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress zrxEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress uniEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress batEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress busdEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress enjEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress kncEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress linkEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress manaEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress mkrEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress renEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress snxEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress susdEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress tusdEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress usdcEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress crvEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress gusdEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress balEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress xsushiEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress renFilEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress raiEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress amplEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress usdpEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress dpiEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress fraxEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');
  // final EthereumAddress feiEthOracleContractAddress =
  //     EthereumAddress.fromHex('hex');

  /// Chainlink Kovan contract address.
  // final EthereumAddress ethUsdOracleContractAddressProxy =
  //     EthereumAddress.fromHex('0x9326BFA02ADD2366b30bacB125260Af641031331');
  // final EthereumAddress ethUsdOracleContractAddress =
  //     EthereumAddress.fromHex('0x10b3c106c4ed7d22b0e7abe5dc43bdfa970a153c');

  // final EthereumAddress feedRegistryContractAddress =
  //     EthereumAddress.fromHex('0xAa7F6f7f507457a1EE157fE97F6c7DB2BEec5cD0');

  /// Token Symbol
  final String ethToken = 'ETH';
  final String denominationEth = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
  final String denominationUSD = '0x0000000000000000000000000000000000000348';
  //TODO:  add other reserve token symbol

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
  final String storageFilename = 'lib/storage.json';

  /// database uri
  final String dbUri = 'mongodb://localhost:27017/${env['DB_NAME']}';

  /// Aave users collection name.
  final String aaveUserCollection = 'aaveUsers';

  /// Aave reserve collection name
  final String aaveReserveCollectionName = 'aaveReserve';
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
