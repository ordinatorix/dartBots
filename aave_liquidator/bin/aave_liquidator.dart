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

  /// Load env and config files.
  load();
  final Config _config = Config();

  /// Connect to db.
  MongodService mongod = MongodService(_config);
  await mongod.isReady;

  /// Connect to blockchain network via infura
  Web3Service _web3 = Web3Service(_config, mongod);
  await _web3.isReady;

  /// EVERY 24hrs
  /// get reserve list => store in db
  /// get reserve config data => store in db
  /// get new users by querying past borrow events
  /// update known users

  /// every 30 min,
  /// get assets price
  /// convert price in ETH

  /// for every asset available on aave
  /// listen for price emmit
  /// convert price in ETH
  /// calc % change from price know to aave
  /// if the price % change >= than the aave price discovery threshold
  /// for each user:
  /// calc new health factor
  /// if new hf < 1 liquidate collateral with highest bonus
  /// update price from aave
  /// if price % change is < than aave price discovery threshold
  /// update user account data
  /// update price from aave

  /// Terminate all conections
  _web3.dispose();
  mongod.closeDb();
}
