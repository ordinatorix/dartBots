import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

void main() async {
  final log = getLogger('main');
  Logger.level = Level.info;
  log.v('Success, We\'re In!');
  load();
 final  Config _config = Config();

  MongodService mongod = MongodService(_config);
  await mongod.isReady;

  Web3Service _web3 = Web3Service(_config, mongod);

  await _web3.isReady;

  _web3.dispose();
  mongod.closeDb();
}
