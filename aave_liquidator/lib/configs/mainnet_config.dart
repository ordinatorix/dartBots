import 'package:dotenv/dotenv.dart';
import 'package:web3dart/credentials.dart';

/// Alchemy api url
final String apiUrl =
    'https://eth-mainnet.alchemyapi.io/v2/${env['ALCHEMY_MAINNET_API_KEY']}';
final String apiWssUri =
    'wss://eth-mainnet.alchemyapi.io/v2/${env['ALCHEMY_MAINNET_API_KEY']}';

/// Aave Mainnet Contract addresses
///
final lendingPoolAddressProviderContractAddress =
    EthereumAddress.fromHex('0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5'); //

final protocolDataProviderContractAddress =
    EthereumAddress.fromHex('0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d'); //

/// Chainlink Mainnet contract addresses
///

final feedRegistryContractAddress =
    EthereumAddress.fromHex('0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf');

// final EthereumAddress ethUsdOracleContractAddressProxy =
//     EthereumAddress.fromHex('0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419');

// final EthereumAddress ethUsdOracleContractAddress =
//     EthereumAddress.fromHex('0x37bC7498f4FF12C19678ee8fE19d713b87F6a9e6');

/// Aave users collection name.
final String aaveUserCollection = 'mainnetAaveUsers';

/// Aave reserve collection name
final String aaveReserveCollection = 'mainnetAaveReserve';
