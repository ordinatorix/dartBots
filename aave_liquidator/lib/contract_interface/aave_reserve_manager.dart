import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveReserveManager');

class AaveReserveManager {
  late Web3Service _web3service;
  late Config _config;
  late MongodService _store;
  AaveReserveManager(Web3Service web3, Config config, MongodService mongod) {
    _web3service = web3;
  }

  /// Get Aave reserve list.
  ///TODO: save  list in DB
  Future<List<EthereumAddress>> getAaveReserveList() async {
    log.i('getting reserve list');

    try {
      List<EthereumAddress> reserveList =
          await _web3service.lendingPoolContract.getReservesList();

      return reserveList;
    } catch (e) {
      log.e('error getting aave reserve list: $e');
      throw 'Could not get aave reserve list.';
    }
  }

  /// Get reserve configuration data
  /// TODO:
  ///
}
