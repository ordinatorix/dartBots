import 'dart:async';

import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/logger.dart';

import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';

import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final log = getLogger('Web3Service');

class Web3Service {
  late Config _config;

  Web3Service(Config config, MongodService mongod) {
    _config = config;
    _initWeb3Client();
  }

  bool _isListenning = false;
  Future<bool> get isReady => pare.future;

  late Web3Client web3Client;
  late int chainId;
  final Client _httpClient = Client();

  late CredentialsWithKnownAddress credentials;

  final Completer<bool> pare = Completer<bool>();

  _initWeb3Client() async {
    await _connectViaRpcApi();
    _getCredentials();

    pare.complete(_isListenning);
  }

  dispose() {
    log.i('disposing web3');
  }

  /// Connect to blockchain using address in localhost
  Future<void> _connectViaRpcApi() async {
    log.i('connecting using to blockchain');
    try {
      web3Client = Web3Client(_config.apiUrl, _httpClient, socketConnector: () {
        return WebSocketChannel.connect(Uri.parse(_config.apiWssUri))
            .cast<String>();
      });
      chainId = await web3Client.getNetworkId();
      log.v('current chainID: $chainId');
      _isListenning = await web3Client.isListeningForNetwork();
      await getCurrentBlock();
      log.v('web3Client is listening: $_isListenning');
    } catch (e) {
      log.e('error connecting to blockchain: $e');
    }
  }

  /// Connect wallet
  _getCredentials() {
    log.i('getting credentials');
    if (env['WALLET_PRIVATE_KEY_0'] != null) {
      credentials = EthPrivateKey.fromHex(env['WALLET_PRIVATE_KEY_0']!);
      log.v('credential address: ${credentials.address}');
    } else {
      log.w('private key not found. This behavior is unexpected');
      throw 'private key not found';
    }
  }

  /// Get current wallet balance
  Future<int> getCurrentBalance() async {
    log.i('getting balance');
    final balance = await web3Client.getBalance(credentials.address);
    log.v('balance: $balance');
    return balance.getInWei.toInt();
  }

// Get current Block
  Future<int> getCurrentBlock() async {
    log.i('getCurrentBlock');
    final blockNumber = await web3Client.getBlockNumber();
    log.v('BlockNumber: $blockNumber');
    return blockNumber;
  }
}
