import 'package:web3dart/credentials.dart';

/// Alchemy api url
final String apiUrl = 'http://127.0.0.1:8545';
final String apiWssUri = 'ws://127.0.0.1:8545';

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

/// Aave users collection name.
final String aaveUserCollection = 'localNetAaveUsers';

/// Aave reserve collection name
final String aaveReserveCollection = 'localNetAaveReserve';
