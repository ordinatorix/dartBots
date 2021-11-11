import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_deposit_event.dart';
import 'package:aave_liquidator/model/aave_repay_event.dart';
import 'package:aave_liquidator/model/aave_withdraw_event.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:aave_liquidator/helper/aave_event_parser.dart';

final log = getLogger('AaveLendingPoolEventListeners');

class AaveLendingPoolEventManager {
  AaveLendingPoolEventManager({
    required Web3Service web3,
    required Config config,
    // required MongodService mongod,
    required AaveContracts aaveContracts,
  }) {
    _web3service = web3;
    _config = config;
    _aaveContracts = aaveContracts;
    _eventParser = AaveEventParser(_aaveContracts);
  }
  late Web3Service _web3service;
  late Config _config;

  late AaveContracts _aaveContracts;
  late AaveEventParser _eventParser;

  /// Extract user address from borrow event
  ///
  /// Returns a [List] of user addresses as [String]  .
  List<String> extractUserAddressFromBorrowEvent(
      List<AaveBorrowEvent> eventsList) {
    log.i('extracting user address from borrow event');
    if (eventsList.isNotEmpty) {
      List<String> _userList = [];
      for (var event in eventsList) {
        if (!_userList.contains(event.onBehalfOf)) {
          _userList.add(event.onBehalfOf);
          log.v('adding ${event.onBehalfOf} to list');
        }
      }
      log.v('_userList: $_userList');
      return _userList;
    } else {
      log.w('events list was null');
      return [];
    }
  }

  /// Query events by contract, filtering by block and address
  queryEventsByContract() async {
    log.i('querying block');
    try {
      /// Create filter
      final _filterOptions = FilterOptions(
        fromBlock: BlockNum.exact(27713385),
        toBlock: BlockNum.exact(27713385),
        address: _config.lendingPoolProxyContractAddress,
      );

      /// Query block for matching logs
      List<FilterEvent> logs =
          await _web3service.web3Client.getLogs(_filterOptions);
      log.d('Data: ${logs[0].data} \n Topics: ${logs[0].topics}');
    } catch (e) {
      log.e('error querying events by contract: $e');
    }
  }

  /// Query borrow event
  Future<List<AaveBorrowEvent>> queryBorrowEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying borrow event | fromBlock: $fromBlock, toBlock: $toBlock');
    try {
      /// Create filter
      FilterOptions _filter = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        fromBlock:
            fromBlock != null ? BlockNum.exact(fromBlock) : BlockNum.current(),
        toBlock: toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
        topics: [
          [_config.encodedBorrowEventTopic]
        ],
      );

      /// Query block for matching logs.
      List<FilterEvent> _borrowEvent =
          await _web3service.web3Client.getLogs(_filter);

      log.v('borrow event: $_borrowEvent');

      return _borrowEvent
          .map((e) => _eventParser.parseEventToAaveBorrowEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying borrow event: $e');
      throw 'Could not get borrow events';
    }
  }

  /// Query deposit event.
  Future<List<AaveDepositEvent>> queryDepositEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying deposit event');
    try {
      /// Create filter.
      FilterOptions _filter = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        fromBlock:
            fromBlock != null ? BlockNum.exact(fromBlock) : BlockNum.current(),
        toBlock: toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
        topics: [
          [_config.encodedDepositEventTopic]
        ],
      );

      /// Query block for matching logs.
      List<FilterEvent> _depositEvent =
          await _web3service.web3Client.getLogs(_filter);

      return _depositEvent
          .map((e) => _eventParser.parseEventToAaveDepositEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying deposit event: $e');
      throw ' Could no get deposit events';
    }
  }

  /// Query repay event.
  Future<List<AaveRepayEvent>> queryRepayEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying repay event');
    try {
      /// Create filter.
      FilterOptions _filter = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        fromBlock:
            fromBlock != null ? BlockNum.exact(fromBlock) : BlockNum.current(),
        toBlock: toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
        topics: [
          [_config.encodedRepayEventTopic]
        ],
      );

      /// Query blocks for matching logs.
      List<FilterEvent> _repayEvent =
          await _web3service.web3Client.getLogs(_filter);

      return _repayEvent
          .map((e) => _eventParser.parseEventToAaveRepayEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying repay event: $e');
      throw 'Could not get repay event';
    }
  }

  /// Query withdraw event.
  Future<List<AaveWithdrawEvent>> queryWithdrawEvent(
      {int? fromBlock, int? toBlock}) async {
    log.d('querying repay event');
    try {
      /// Create filter
      FilterOptions _filter = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        fromBlock:
            fromBlock != null ? BlockNum.exact(fromBlock) : BlockNum.current(),
        toBlock: toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
        topics: [
          [_config.encodedWithdrawEventTopic]
        ],
      );

      /// Query locks for logs
      List<FilterEvent> _withdrawEvent =
          await _web3service.web3Client.getLogs(_filter);

      return _withdrawEvent
          .map(
              (e) => _eventParser.parseEventToAaveWithdrawEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying withdraw event: $e');
      throw 'Could not get withdraw event';
    }
  }

  /// Listen for borrow events.
  /// TODO: for any user in db
  /// update user data.
  listenForBorrowEvents() {
    log.i('listenning for borrow event');

    _aaveContracts.lendingPoolContract.borrowEvents().listen((_borrow) {
      log.d('new borrow event: $_borrow');
      _eventParser.parseEventToAaveBorrowEvent(borrow: _borrow);
    });
  }

  /// Listen for deposit events.
  /// TODO: for any user in db
  /// update user data
  listenForDepositEvent() {
    log.i('listenning for deposit event');

    _aaveContracts.lendingPoolContract.depositEvents().listen((_deposit) {
      log.d('new deposit event: $_deposit');

      _eventParser.parseEventToAaveDepositEvent(deposit: _deposit);
    });
  }

  /// listen for repay event
  /// TODO: for any event from user in db,
  /// update user data.
  listenForRepayEvent() {
    log.i('listenning for repay event');

    _aaveContracts.lendingPoolContract.repayEvents().listen((_repay) {
      log.d('new repay event: $_repay');
      _eventParser.parseEventToAaveRepayEvent(repay: _repay);
    });
  }

  /// listen for withdraw event
  /// TODO: for any user in db
  /// update user data.
  listenForWithdrawEvent() {
    log.i('listenning for withdraw event');
    _aaveContracts.lendingPoolContract.withdrawEvents().listen((_withdraw) {
      log.d('new withdraw event: $_withdraw');
      _eventParser.parseEventToAaveWithdrawEvent(withdraw: _withdraw);
    });
  }

  /// listen for liquidation call events
  /// TODO:

  listenForLiquidationcall() {
    log.i('listenning for liquidation call events');
    _aaveContracts.lendingPoolContract
        .liquidationCallEvents()
        .listen((_liqCall) {
      log.d('new liquidation call event: $_liqCall');
      // TODO: parse liquidation call event.
    });
  }
}
