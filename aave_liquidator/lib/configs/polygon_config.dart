import 'package:dotenv/dotenv.dart';
import 'package:web3dart/credentials.dart';

/// Infura api url
// apiUrl = 'https://kovan.infura.io/v3/${env['INFURA_API_KEY']}';
// apiWssUri = 'wss://kovan.infura.io/ws/v3/${env['INFURA_API_KEY']}';

/// Alchemy api url
final String apiUrl =
    'https://polygon-mainnet.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';
final String apiWssUri =
    'wss://polygon-mainnet.alchemyapi.io/v2/${env['ALCHEMY_KOVAN_API_KEY']}';

/// Aave Kovan contract address

final lendingPoolAddressProviderContractAddress =
    EthereumAddress.fromHex('0x0'); //

final protocolDataProviderContractAddress = EthereumAddress.fromHex('0x0');

/// Aave users collection name.
final String aaveUserCollection = 'polygonAaveUsers';

/// Aave reserve collection name
final String aaveReserveCollection = 'polygonAaveReserve';

/// Chainlink contract addressed.
final feedRegistryContractAddress = EthereumAddress.fromHex('0x0');

Map<String, EthereumAddress> aggregator = {
  "DAI/ETH":
      EthereumAddress.fromHex("0xFC539A559e170f848323e19dfD66007520510085"),
  "USDC/ETH":
      EthereumAddress.fromHex("0xefb7e6be8356cCc6827799B6A7348eE674A80EaE"),
  "USDT/ETH":
      EthereumAddress.fromHex("0xf9d5AAC6E5572AEFa6bd64108ff86a222F69B64d"),
  "WBTC/ETH":
      EthereumAddress.fromHex("0xA338e0492B2F944E9F8C0653D3AD1484f2657a37"),
  "MATIC/ETH":
      EthereumAddress.fromHex("0x327e23A4855b6F663a28c5161541d69Af8973302"),
  "WETH/USD":
      EthereumAddress.fromHex("0xF9680D99D6C9589e2a93a78A04A279e509205945"),
};
