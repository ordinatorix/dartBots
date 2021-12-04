import 'package:dotenv/dotenv.dart';

import 'package:web3dart/web3dart.dart';

class Config {
  Config({required DeployedNetwork network}) {
    currentNetwork = network;
    _setupNetwork(network);
  }
  late DeployedNetwork currentNetwork;
  late String apiUrl;
  late String apiWssUri;
  late EthereumAddress lendingPoolAddressProviderContractAddress;
    late EthereumAddress protocolDataProviderContractAddress;
  late EthereumAddress feedRegistryContractAddress;
  late String aaveUserCollection;
  late String aaveReserveCollection;

  _setupNetwork(DeployedNetwork network) {
    switch (network) {
      case DeployedNetwork.kovan:
        {
          _kovanAddresses();
        }

        break;
      case DeployedNetwork.mainnet:
        {
          _mainnetAddresses();
        }

        break;
      case DeployedNetwork.polygon:
        {}

        break;
      case DeployedNetwork.avalanche:
        {}

        break;
      default:
    }
  }

  // /// Token Symbol
  final String ethToken = 'ETH';
  final String denominationEth = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
  final String denominationUSD = '0x0000000000000000000000000000000000000348';

  _mainnetAddresses() {
   

    /// Alchemy api url
    apiUrl =
        'https://eth-mainnet.alchemyapi.io/v2/${env['ALCHEMY_MAINNET_API_KEY']}';
    apiWssUri =
        'wss://eth-mainnet.alchemyapi.io/v2/${env['ALCHEMY_MAINNET_API_KEY']}';

    /// Aave Mainnet Contract addresses
    ///
    lendingPoolAddressProviderContractAddress = EthereumAddress.fromHex(
        '0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5'); //



    protocolDataProviderContractAddress = EthereumAddress.fromHex(
        '0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d'); //


    /// Chainlink Mainnet contract addresses
    ///

    feedRegistryContractAddress =
        EthereumAddress.fromHex('0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf');

    // final EthereumAddress ethUsdOracleContractAddressProxy =
    //     EthereumAddress.fromHex('0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419');

    // final EthereumAddress ethUsdOracleContractAddress =
    //     EthereumAddress.fromHex('0x37bC7498f4FF12C19678ee8fE19d713b87F6a9e6');

    /// Aave users collection name.
    aaveUserCollection = 'mainnetAaveUsers';

    /// Aave reserve collection name
    aaveReserveCollection = 'mainnetAaveReserve';
  }

  _kovanAddresses() {
    /// Infura api url
    // apiUrl = 'https://kovan.infura.io/v3/${env['INFURA_API_KEY']}';
    // apiWssUri = 'wss://kovan.infura.io/ws/v3/${env['INFURA_API_KEY']}';

    /// Alchemy api url
    apiUrl =
        'https://eth-kovan.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';
    apiWssUri =
        'wss://eth-kovan.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';

    /// Aave Kovan contract address

    lendingPoolAddressProviderContractAddress = EthereumAddress.fromHex(
        '0x88757f2f99175387aB4C6a4b3067c77A695b0349'); //
    // lendingPoolProxyContractAddress =
    //     EthereumAddress.fromHex('0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe');


    protocolDataProviderContractAddress =
        EthereumAddress.fromHex('0x3c73A5E5785cAC854D468F727c606C07488a29D6');


    /// Chainlink feed registry
    feedRegistryContractAddress =
        EthereumAddress.fromHex('0xAa7F6f7f507457a1EE157fE97F6c7DB2BEec5cD0');

    /// Aave users collection name.
    aaveUserCollection = 'kovanAaveUsers';

    /// Aave reserve collection name
    aaveReserveCollection = 'kovanAaveReserve';
  }

  // /// ---------------------Aave configs--------------------------------
  // /// Encoded topics
  // final String encodedBorrowEventTopic =
  //     '0xc6a898309e823ee50bac64e45ca8adba6690e99e7841c45d754e2a38e9019d9b';
  // final String encodedDepositEventTopic =
  //     '0xde6857219544bb5b7746f48ed30be6386fefc61b2f864cacf559893bf50fd951';
  // final String encodedRepayEventTopic =
  //     '0x4cdde6e09bb755c9a5589ebaec640bbfedff1362d4b255ebf8339782b9942faa';
  // final String encodedWithdrawEventTopic =
  //     '0x3115d1449a7b732c986cba18244e897a450f61e1bb8d589cd2e69e6c8924f9f7';

  /// minimum health factor to take interest in. value is in wei
  final BigInt focusHealthFactor = BigInt.parse('1500000000000000000');

  /// Liquidators can only close a certain amount of collateral defined by a close factor.
  /// Currently the close factor is 0.5. In other words, liquidators can only liquidate a
  /// maximum of 50% of the amount pending to be repaid in a position.
  final double closeFactor = 0.5;

  /// --------------------database configs----------------------

  /// database uri
  final String dbUri = 'mongodb://localhost:27017/${env['DB_NAME']}';
}

enum DeployedNetwork {
  kovan,
  mainnet,
  polygon,
  avalanche,
}
