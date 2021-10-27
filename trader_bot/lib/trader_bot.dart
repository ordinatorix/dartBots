import 'package:trader_bot/abi/sushi_router.g.dart';
import 'package:web3dart/web3dart.dart';

class PriceBot {
  late Web3Client web3client;
  PriceBot(Web3Client _client) {
    web3client = _client;
  }
  //TODO: approve swap
  // instacniate router contract
  // final sushiSwapRouter =
      // Sushi_router(address: EthereumAddress.fromHex('hex'), client: web3client);
  //get price of asset
}
