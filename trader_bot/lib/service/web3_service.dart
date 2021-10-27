import 'package:http/http.dart';
import 'package:trader_bot/config.dart';
import 'package:trader_bot/logger.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('Web3Service');

class Web3Service {
  Web3Service() {
    _config = Config();
    _connectViaRpcApi();
  }

  late Config _config;
  bool _isListenning = false;
  bool get isReady => _isListenning;
  Web3Client get currentClient => _web3Client;

  late Web3Client _web3Client;
  late int _chainId;
  final Client _httpClient = Client();

  /// Connect to blockchain using address in localhost
  Future<void> _connectViaRpcApi() async {
    log.i('connecting using Infura');

    _web3Client = Web3Client(_config.kovanApiUrl, _httpClient);
    _chainId = await _web3Client.getNetworkId();
    log.d('current chainID: $_chainId');
    _isListenning = await _web3Client.isListeningForNetwork();
    log.d('web3Client is listening: $_isListenning');
  }
}
