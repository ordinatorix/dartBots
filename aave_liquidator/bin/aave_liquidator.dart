import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/web3_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

void main() {
  final log = getLogger('main');
  Logger.level = Level.info;
  log.v('Success, We\'re In!');

  load();
  Web3Service _web3 = Web3Service();

  _web3.dispose();
}
