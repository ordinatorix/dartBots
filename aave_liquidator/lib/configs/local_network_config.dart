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

/// Aave users collection name.
final String aaveUserCollection = 'localNetAaveUsers';

/// Aave reserve collection name
final String aaveReserveCollection = 'localNetAaveReserve';

/// ChainLink feed registry address.
final feedRegistryContractAddress =
    EthereumAddress.fromHex('0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf');

/// Chainlink aggregator proxy address.
final Map<String, EthereumAddress> aggregator = {
  "DAI/ETH":
      EthereumAddress.fromHex("0x773616E4d11A78F511299002da57A0a94577F1f4"),
  "USDC/ETH":
      EthereumAddress.fromHex("0x986b5E1e1755e3C2440e960477f25201B0a8bbD4"),
  "USDT/ETH":
      EthereumAddress.fromHex("0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46"),
  "WBTC/ETH":
      EthereumAddress.fromHex("0xdeb288F737066589598e9214E782fa5A8eD689e8"),
  "WETH/USD":
      EthereumAddress.fromHex("0xF7904a295A029a3aBDFFB6F12755974a958C7C25"),
};
