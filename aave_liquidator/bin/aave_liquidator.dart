import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/contract_interface/aave_lending_pool_event_manager.dart';
import 'package:aave_liquidator/contract_interface/aave_reserve_manager.dart';
import 'package:aave_liquidator/contract_interface/aave_user_manager.dart';
import 'package:aave_liquidator/contract_interface/chain_link_interface.dart';
import 'package:aave_liquidator/helper/contract_helpers/liquidator_contract.dart';
import 'package:aave_liquidator/enums/deployed_networks.dart';
import 'package:aave_liquidator/helper/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/helper/contract_helpers/chainlink_contracts.dart';
import 'package:aave_liquidator/helper/network_prompt.dart';

import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';

import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logger/logger.dart';

final log = getLogger('main');
void main() async {
  /// set debug level
  Logger.level = Level.verbose;
  log.v('Success, We\'re In!');

  /// Load env
  load();

  // int _userSelection = requireNetworkSelection();
  int _userSelection = 0;
  var _selectedNetwork = DeployedNetwork.values[_userSelection];

  print('running app using $_selectedNetwork');

  /// setup configs
  final Config _config = Config(network: _selectedNetwork);

  /// Connect to db.
  final MongodService _mongodService = MongodService(_config);
  await _mongodService.isReady;

  /// Connect to blockchain network via infura
  final Web3Service _web3 = Web3Service(_config, _mongodService);
  await _web3.isReady;

  /// Setup aave contracts
  final AaveContracts _aaveContracts = AaveContracts(_web3, _config);

  /// setup chainlink contracts
  final ChainlinkContracts _chainlinkContracts =
      ChainlinkContracts(_web3, _config);

  /// setup liquidator contract.
  final LiquidatorContract _liquidatorContract =
      LiquidatorContract(web3: _web3, aaveContracts: _aaveContracts);

  /// wait for chainlink contracts to be ready.
  await _chainlinkContracts.isReady;

  /// setup price oracle.
  final ChainLinkPriceOracle _oracle = ChainLinkPriceOracle(
    chainlinkContracts: _chainlinkContracts,
    config: _config,
    mongod: _mongodService,
  );

  final AaveReserveManager _reserveManager = AaveReserveManager(
    // config: _config,
    mongod: _mongodService,
    aaveContracts: _aaveContracts,
  );

  final AaveUserManager _userManager = AaveUserManager(
    config: _config,
    mongod: _mongodService,
    aaveContracts: _aaveContracts,
  );

  final AaveLendingPoolEventManager _lendingPoolEventManager =
      AaveLendingPoolEventManager(
    web3: _web3,
    aaveContracts: _aaveContracts,
  );

  /// Poll Aave reserves
  ///
  /// This will be a scheduled task to update reserve data periodically
  /// TODO: create 24hr cron repeat interval.

  await _reserveManager.pollReserveData(oracle: _oracle);

  /// Poll Aave for new users
  ///
  /// Update list of users in db.
  /// TODO: create 24hr cron repeat interval.
  _pollNewUsers() async {
    log.i('_pollNewUsers');
    try {
      /// get current block
      final _currentBlock = await _web3.getCurrentBlock();

      List<AaveBorrowEvent> _borrowEvents = [];
      final startingBlock = 12900000; //12341000;
      final increment = 2000;
      for (var i = startingBlock; i <= _currentBlock; i += increment) {
        log.d('segment: $i');
        final _fromBlock = i;
        final _toBlock = i + increment;
        print('from:$_fromBlock');
        print('to:$_toBlock');
        final _borrowEventsSegment = await _lendingPoolEventManager
            .queryBorrowEvent(fromBlock: _fromBlock, toBlock: _toBlock);
        log.d('_borrowEvents found :${_borrowEventsSegment.length}');
        _borrowEvents.addAll(_borrowEventsSegment);
      }
      final _userList = _lendingPoolEventManager
          .extractUserAddressFromBorrowEvent(_borrowEvents);

      await _userManager.getUserAccountData(userList: _userList);
    } catch (e) {
      log.e('error polling new users: $e');
    }
  }

  // await _pollNewUsers();

  final List<AaveUserAccountData> riskyUser = await _userManager
      .getUserAccountData(
          userList: ['0x3489198047510dc393f158d12a45c737e233c524']);
  log.wtf('yes: ${riskyUser[0].healthFactor}');

  // every 30 min,
  // get assets price

  /// For every asset available on aave.
  /// Listen for price changes.
  ///
  _oracle.priceListener();

  // liquidate user.
  await _liquidatorContract.liquidateAaveUser(
    collateralAsset: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
    debtAsset: '0x6b175474e89094c44da98b954eedeac495271d0f',
    user: '0x3489198047510dc393f158d12a45c737e233c524',
    // debtToCover: BigInt.parse('45722211231980037'),
    debtToCover: BigInt.parse('213896121822239717418'),
    useEthPath: false,
  );

  /// Terminate all conections
  _web3.dispose();
  _mongodService.closeDb();
}
