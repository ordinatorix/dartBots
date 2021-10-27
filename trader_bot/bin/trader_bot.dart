import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';
import 'package:trader_bot/logger.dart';
import 'package:trader_bot/service/web3_service.dart';
import 'package:trader_bot/trader_bot.dart';

void main(List<String> arguments) async {
  final log = getLogger('main');
  Logger.level = Level.info;
  log.v('how much?');

  load();
  Web3Service _web3 = Web3Service();
  PriceBot(_web3.currentClient);
}
