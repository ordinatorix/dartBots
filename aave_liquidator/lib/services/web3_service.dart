// ignore_for_file: avoid_log.

import 'dart:async';

// import 'dart:io';

import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/abi/chainlink_eth_usd_oracle.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';

import 'package:aave_liquidator/model/aave_withdraw_event.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';

import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_deposit_event.dart';
import 'package:aave_liquidator/model/aave_repay_event.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';

import 'package:web3dart/web3dart.dart';

final log = getLogger('Web3Service');

class Web3Service {
  late Config _config;
  late MongodService _store;
  Web3Service(Config config, MongodService mongod) {
    _store = mongod;
    _config = config;
    _initWeb3Client();
  }

  bool _isListenning = false;
  Future<bool> get isReady => pare.future;

  late Web3Client web3Client;
  late int chainId;
  final Client _httpClient = Client();

  late CredentialsWithKnownAddress credentials;

  late Aave_lending_pool lendingPoolContract;
  late DeployedContract proxyContract;
  late Aave_protocol_data_provider protocolDataProviderContract;
  

  late ContractEvent contractDepositEvent;
  late ContractEvent contractWithdrawEvent;
  late ContractEvent contractBorrowEvent;
  late ContractEvent contractRepayEvent;
  late ContractEvent contractLiquidationCallEvent;

  late List<AaveBorrowEvent> queriedBorrowEvent;
  late List<AaveDepositEvent> queriedDepositEvent;
  late List<AaveRepayEvent> queriedRepayEvent;
  late List<AaveWithdrawEvent> queriedWithdrawEvent;
  List<String> userFromEvents = [];
  List<EthereumAddress> aaveReserveList = [];
  final pare = Completer<bool>();

  _initWeb3Client() async {
    await _connectViaRpcApi();
    _getCredentials();
    await _setupContracts();

    // aaveReserveList = await getAaveReserveList();

    // queriedBorrowEvent = await queryBorrowEvent(fromBlock: 28050000);
    // userFromEvents = _extractUserFromBorrowEvent(queriedBorrowEvent);
    // // queriedDepositEvent = await queryDepositEvent(fromBlock: 27990000);
    // // queriedRepayEvent = await queryRepayEvent(fromBlock: 27990000);
    // // queriedWithdrawEvent = await queryWithdrawEvent(fromBlock: 27990000);
    // // log.v(
    // //     'borrow event: $queriedBorrowEvent; deposit: $queriedDepositEvent; repay: $queriedRepayEvent; withdraw: $queriedWithdrawEvent');

    // await getUserAccountData(userList: userFromEvents);

    pare.complete(_isListenning);
  }

  dispose() {
    log.i('disposing web3');
  }

  /// Connect to blockchain using address in localhost
  Future<void> _connectViaRpcApi() async {
    log.i('connecting using Infura');

    web3Client = Web3Client(_config.kovanApiUrl, _httpClient);
    chainId = await web3Client.getNetworkId();
    log.d('current chainID: $chainId');
    _isListenning = await web3Client.isListeningForNetwork();
    log.d('web3Client is listening: $_isListenning');
  }

  /// Connect wallet
  _getCredentials() {
    log.i('getting credentials');
    credentials = EthPrivateKey.fromHex(env['WALLET_PRIVATE_KEY']!);
  }

  getCurrentBalance() async {
    log.i('getting balance');
    final balance = await web3Client.getBalance(credentials.address);
    log.d(balance);
  }

  /// setup contracts

  _setupContracts() async {
    log.i('setting up contract');
    try {
      lendingPoolContract = Aave_lending_pool(
          address: _config.lendingPoolProxyContractAddress,
          client: web3Client,
          chainId: chainId);

      protocolDataProviderContract = Aave_protocol_data_provider(
          address: _config.protocolDataProviderContractAddress,
          client: web3Client,
          chainId: chainId);

    

      /// setup contract events
      contractDepositEvent = lendingPoolContract.self.event('Deposit');
      contractWithdrawEvent = lendingPoolContract.self.event('Withdraw');
      contractBorrowEvent = lendingPoolContract.self.event('Borrow');
      contractRepayEvent = lendingPoolContract.self.event('Repay');
      contractLiquidationCallEvent =
          lendingPoolContract.self.event('LiquidationCall');
    } catch (e) {
      log.e('error setting up contracts: $e');
    }
  }

  /// Extract user from borrow event
  List<String> _extractUserFromBorrowEvent(List<AaveBorrowEvent> eventsList) {
    log.i('extracting user address from borrow event');
    if (eventsList.isNotEmpty) {
      List<String> _userList = [];
      for (var event in eventsList) {
        if (!_userList.contains(event.onBehalfOf)) {
          _userList.add(event.onBehalfOf);
          log.v('adding ${event.onBehalfOf} to list');
        }
      }

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
          address: _config.lendingPoolProxyContractAddress);

      /// Query block for matching logs
      List<FilterEvent> logs = await web3Client.getLogs(_filterOptions);
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
      List<FilterEvent> _borrowEvent = await web3Client.getLogs(_filter);

      log.v('borrow event: $_borrowEvent');

      return _borrowEvent
          .map((e) => _parseEventToAaveBorrowEvent(filterEvent: e))
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
      List<FilterEvent> _depositEvent = await web3Client.getLogs(_filter);

      return _depositEvent
          .map((e) => _parseEventToAaveDepositEvent(filterEvent: e))
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
      List<FilterEvent> _repayEvent = await web3Client.getLogs(_filter);

      return _repayEvent
          .map((e) => _parseEventToAaveRepayEvent(filterEvent: e))
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
      List<FilterEvent> _withdrawEvent = await web3Client.getLogs(_filter);

      return _withdrawEvent
          .map((e) => _parseEventToAaveWithdrawEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying withdraw event: $e');
      throw 'Could not get withdraw event';
    }
  }

  /// Query specific users
  /// TODO: using [getUserAccountData] update the db with new data from userwith  UltraLow Health Factor (ULHF).
  ///

  /// Listen for borrow events.
  /// TODO: for any user in db
  /// update user data.
  _listenForBorrowEvents() {
    log.i('listenning for borrow event');

    lendingPoolContract.borrowEvents().listen((_borrow) {
      log.d('new borrow event: $_borrow');
      _parseEventToAaveBorrowEvent(borrow: _borrow);
    });
  }

  /// Listen for deposit events.
  /// TODO: for any user in db
  /// update user data
  _listenForDepositEvent() {
    log.i('listenning for deposit event');

    lendingPoolContract.depositEvents().listen((_deposit) {
      log.d('new deposit event: $_deposit');

      _parseEventToAaveDepositEvent(deposit: _deposit);
    });
  }

  /// listen for repay event
  /// TODO: for any event from user in db,
  /// update user data.
  _listenForRepayEvent() {
    log.i('listenning for repay event');

    lendingPoolContract.repayEvents().listen((_repay) {
      log.d('new repay event: $_repay');
      _parseEventToAaveRepayEvent(repay: _repay);
    });
  }

  /// listen for withdraw event
  /// TODO: for any user in db
  /// update user data.
  _listenForWithdrawEvent() {
    log.i('listenning for withdraw event');
    lendingPoolContract.withdrawEvents().listen((_withdraw) {
      log.d('new withdraw event: $_withdraw');
      _parseEventToAaveWithdrawEvent(withdraw: _withdraw);
    });
  }

  /// listen for liquidation call events
  /// TODO:

  _listenForLiquidationcall() {
    log.i('listenning for liquidation call events');
    lendingPoolContract.liquidationCallEvents().listen((_liqCall) {
      log.d('new liquidation call event: $_liqCall');
      // TODO: parse liquidation call event.
    });
  }

  /// parse borrow event data and topics
  AaveBorrowEvent _parseEventToAaveBorrowEvent(
      {Borrow? borrow, FilterEvent? filterEvent}) {
    log.v('parsing borrow event');
    late AaveBorrowEvent parsedBorrowEvent;
    if (filterEvent != null) {
      final List _decodedResult = contractBorrowEvent.decodeResults(
          filterEvent.topics!, filterEvent.data!);
      parsedBorrowEvent = AaveBorrowEvent(
        userAddress: _decodedResult[1].toString(),
        onBehalfOf: _decodedResult[2].toString(),
        reserve: _decodedResult[0].toString(),
        amount: double.parse(_decodedResult[3].toString()),
        borrowRateMode: double.parse(_decodedResult[4].toString()),
        borrowRate: double.parse(_decodedResult[5].toString()),
      );
    } else {
      parsedBorrowEvent = AaveBorrowEvent(
        userAddress: borrow!.user.toString(),
        onBehalfOf: borrow.onBehalfOf.toString(),
        reserve: borrow.reserve.toString(),
        amount: borrow.amount.toDouble(),
        borrowRateMode: borrow.borrowRateMode.toDouble(),
        borrowRate: borrow.borrowRate.toDouble(),
      );
    }

    return parsedBorrowEvent;
  }

  /// Parse deposit event data and topics.
  AaveDepositEvent _parseEventToAaveDepositEvent(
      {Deposit? deposit, FilterEvent? filterEvent}) {
    log.v('parsing deposit event');
    late AaveDepositEvent parsedDepositEvent;
    if (filterEvent != null) {
      final List _decodedResult = contractDepositEvent.decodeResults(
          filterEvent.topics!, filterEvent.data!);

      parsedDepositEvent = AaveDepositEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        onBehalfOf: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedDepositEvent = AaveDepositEvent(
        reserve: deposit!.reserve.toString(),
        userAddress: deposit.user.toString(),
        onBehalfOf: deposit.onBehalfOf.toString(),
        amount: deposit.amount.toDouble(),
      );
    }

    return parsedDepositEvent;
  }

  /// Parse repay event
  AaveRepayEvent _parseEventToAaveRepayEvent(
      {Repay? repay, FilterEvent? filterEvent}) {
    log.v('parsing repay event: $filterEvent');
    late AaveRepayEvent parsedRepayEvent;
    if (filterEvent != null) {
      final List _decodedResult = contractRepayEvent.decodeResults(
          filterEvent.topics!, filterEvent.data!);

      parsedRepayEvent = AaveRepayEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        repayer: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedRepayEvent = AaveRepayEvent(
        reserve: repay!.reserve.toString(),
        userAddress: repay.user.toString(),
        repayer: repay.repayer.toString(),
        amount: repay.amount.toDouble(),
      );
    }

    return parsedRepayEvent;
  }

  /// Parse withdraw event.
  AaveWithdrawEvent _parseEventToAaveWithdrawEvent(
      {Withdraw? withdraw, FilterEvent? filterEvent}) {
    log.d('parsing withdraw event');
    late AaveWithdrawEvent parsedWithdrawEvent;
    if (filterEvent != null) {
      List _decodedResult = contractWithdrawEvent.decodeResults(
          filterEvent.topics!, filterEvent.data!);

      log.d('decoded withdraw event: $_decodedResult');
      parsedWithdrawEvent = AaveWithdrawEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        to: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedWithdrawEvent = AaveWithdrawEvent(
        reserve: withdraw!.reserve.toString(),
        userAddress: withdraw.user.toString(),
        to: withdraw.to.toString(),
        amount: withdraw.amount.toDouble(),
      );
    }
    log.d(parsedWithdrawEvent);
    return parsedWithdrawEvent;
  }
}

class MyContractEvent extends ContractEvent {
  MyContractEvent(bool anonymous, String name, List<EventComponent> components)
      : super(anonymous, name, components);
}
