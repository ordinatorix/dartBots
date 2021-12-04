import 'package:aave_liquidator/enums/deployed_networks.dart';
import 'package:dotenv/dotenv.dart';
import './mainnet_config.dart' as mainnet;
import './kovan_config.dart' as kovan;
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
          _setupKovan();
        }

        break;
      case DeployedNetwork.mainnet:
        {
          _setupMainnet();
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

  _setupKovan() {
    apiUrl = kovan.apiUrl;
    apiWssUri = kovan.apiWssUri;
    lendingPoolAddressProviderContractAddress =
        kovan.lendingPoolAddressProviderContractAddress;
    protocolDataProviderContractAddress =
        kovan.protocolDataProviderContractAddress;
    feedRegistryContractAddress = kovan.feedRegistryContractAddress;
    aaveUserCollection = kovan.aaveUserCollection;
    aaveReserveCollection = kovan.aaveReserveCollection;
  }

  _setupMainnet() {
    apiUrl = mainnet.apiUrl;
    apiWssUri = mainnet.apiWssUri;
    lendingPoolAddressProviderContractAddress =
        mainnet.lendingPoolAddressProviderContractAddress;
    protocolDataProviderContractAddress =
        mainnet.protocolDataProviderContractAddress;
    feedRegistryContractAddress = mainnet.feedRegistryContractAddress;
    aaveUserCollection = mainnet.aaveUserCollection;
    aaveReserveCollection = mainnet.aaveReserveCollection;
  }
  _setupLocalNet(){}

  // /// Token Symbol
  final String ethToken = 'ETH';
  final String denominationEth = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
  final String denominationUSD = '0x0000000000000000000000000000000000000348';

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
