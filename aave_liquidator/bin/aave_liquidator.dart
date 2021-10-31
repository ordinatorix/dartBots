import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

final log = getLogger('main');
void main() async {
  Logger.level = Level.info;
  log.v('Success, We\'re In!');
  load();
  final Config _config = Config();

  MongodService mongod = MongodService(_config);
  await mongod.isReady;

/// TODO:
/// check to see if database is empty
///   -> query blockchain for borrow events
///   !-> query users based on preset frequency.
/// 
  Web3Service _web3 = Web3Service(_config, mongod);

  await _web3.isReady;

  _web3.dispose();
  mongod.closeDb();
}
