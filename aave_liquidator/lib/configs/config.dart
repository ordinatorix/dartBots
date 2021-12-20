import 'package:aave_liquidator/enums/deployed_networks.dart';
import 'package:dotenv/dotenv.dart';
import './mainnet_config.dart' as mainnet;
import './kovan_config.dart' as kovan;
import './local_network_config.dart' as local_net;
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
  late Map<String, EthereumAddress> aggregatorAddress;

  _setupNetwork(DeployedNetwork network) {
    switch (network) {
      case DeployedNetwork.local:
        {
          _setupLocalNet();
        }

        break;
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
        () {
          _setupLocalNet();
        };
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
    aggregatorAddress = kovan.aggregator;
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

  _setupLocalNet() {
    apiUrl = local_net.apiUrl;
    apiWssUri = local_net.apiWssUri;
    lendingPoolAddressProviderContractAddress =
        local_net.lendingPoolAddressProviderContractAddress;
    protocolDataProviderContractAddress =
        local_net.protocolDataProviderContractAddress;
    feedRegistryContractAddress = local_net.feedRegistryContractAddress;
    aaveUserCollection = local_net.aaveUserCollection;
    aaveReserveCollection = local_net.aaveReserveCollection;
    aggregatorAddress = local_net.aggregator;
  }

  final String denominationEth = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
  final String denominationBtc = '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB';

  final String denominationUSD = '0x0000000000000000000000000000000000000348';

  /// minimum health factor to take interest in. value is in wei
  final BigInt focusHealthFactor = BigInt.parse('1200000000000000000');

  /// Liquidators can only close a certain amount of collateral defined by a close factor.
  /// Currently the close factor is 0.5. In other words, liquidators can only liquidate a
  /// maximum of 50% of the amount pending to be repaid in a position.
  final double closeFactor = 0.5;

  /// --------------------database configs----------------------

  /// database uri
  final String dbUri = 'mongodb://localhost:27017/${env['DB_NAME']}';
}
