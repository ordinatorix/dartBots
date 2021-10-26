import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/web3_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

void main(List<String> arguments) {
  final log = getLogger('main');
  Logger.level = Level.debug;
  log.v('Success, We\'re In!');

  load();
  Web3Service _web3 = Web3Service();

  _web3.dispose();
}
