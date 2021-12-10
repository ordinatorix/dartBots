import 'package:dotenv/dotenv.dart';
import 'package:web3dart/credentials.dart';

/// Infura api url
// apiUrl = 'https://kovan.infura.io/v3/${env['INFURA_API_KEY']}';
// apiWssUri = 'wss://kovan.infura.io/ws/v3/${env['INFURA_API_KEY']}';

/// Alchemy api url
final String apiUrl =
    'https://eth-kovan.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';
final String apiWssUri =
    'wss://eth-kovan.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';

/// Aave Kovan contract address

final lendingPoolAddressProviderContractAddress =
    EthereumAddress.fromHex('0x88757f2f99175387aB4C6a4b3067c77A695b0349'); //

final protocolDataProviderContractAddress =
    EthereumAddress.fromHex('0x3c73A5E5785cAC854D468F727c606C07488a29D6');

/// Chainlink feed registry
final feedRegistryContractAddress =
    EthereumAddress.fromHex('0xAa7F6f7f507457a1EE157fE97F6c7DB2BEec5cD0');

/// Aave users collection name.
final String aaveUserCollection = 'kovanAaveUsers';

/// Aave reserve collection name
final String aaveReserveCollection = 'kovanAaveReserve';

Map<String, EthereumAddress> aggregator = {
  "DAI/ETH":
      EthereumAddress.fromHex("0x22B58f1EbEDfCA50feF632bD73368b2FdA96D541"),
  "USDC/ETH":
      EthereumAddress.fromHex("0x64EaC61A2DFda2c3Fa04eED49AA33D021AeC8838"),
  "USDT/ETH":
      EthereumAddress.fromHex("0x0bF499444525a23E7Bb61997539725cA2e928138"),
  "WBTC/ETH":
      EthereumAddress.fromHex("0xF7904a295A029a3aBDFFB6F12755974a958C7C25"),
  "ETH/USD":
      EthereumAddress.fromHex("0x9326BFA02ADD2366b30bacB125260Af641031331"),
};
