// ignore_for_file: avoid_log.

import 'dart:async';

import 'dart:io';

import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
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

  late Web3Client _web3Client;
  late int _chainId;
  final Client _httpClient = Client();

  late CredentialsWithKnownAddress credentials;

  late Aave_lending_pool lendingPoolContract;
  late DeployedContract proxyContract;
  late Aave_protocol_data_provider protocolDataProviderContract;

  late ContractEvent contractDepositEvent;
  late ContractEvent contractWithdrawEvent;
  late ContractEvent contractBorrowEvent;
  late ContractEvent contractRepayEvent;

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
    aaveReserveList = await getAaveReserveList();

    queriedBorrowEvent = await queryBorrowEvent(fromBlock: 28050000);
    userFromEvents = _extractUserFromBorrowEvent(queriedBorrowEvent);
    // queriedDepositEvent = await queryDepositEvent(fromBlock: 27990000);
    // queriedRepayEvent = await queryRepayEvent(fromBlock: 27990000);
    // queriedWithdrawEvent = await queryWithdrawEvent(fromBlock: 27990000);
    // log.v(
    //     'borrow event: $queriedBorrowEvent; deposit: $queriedDepositEvent; repay: $queriedRepayEvent; withdraw: $queriedWithdrawEvent');
   
        await getUserAccountData(userList: userFromEvents);
   

    pare.complete(true);
  }

  dispose() {
    log.i('disposing web3');
  }

  /// Connect to blockchain using address in localhost
  Future<void> _connectViaRpcApi() async {
    log.i('connecting using Infura');

    _web3Client = Web3Client(_config.kovanApiUrl, _httpClient);
    _chainId = await _web3Client.getNetworkId();
    log.d('current chainID: $_chainId');
    _isListenning = await _web3Client.isListeningForNetwork();
    log.d('web3Client is listening: $_isListenning');
  }

  /// Connect wallet
  _getCredentials() {
    log.i('getting credentials');
    credentials = EthPrivateKey.fromHex(env['WALLET_PRIVATE_KEY']!);
  }

  getCurrentBalance() async {
    log.i('getting balance');
    final balance = await _web3Client.getBalance(credentials.address);
    log.d(balance);
  }

  /// setup contracts

  _setupContracts() async {
    log.i('setting up contract');
    try {
      lendingPoolContract = Aave_lending_pool(
          address: _config.lendingPoolProxyContractAddress,
          client: _web3Client,
          chainId: _chainId);

      protocolDataProviderContract = Aave_protocol_data_provider(
          address: _config.protocolDataProviderContractAddress,
          client: _web3Client,
          chainId: _chainId);

      /// setup contract events

      contractDepositEvent = lendingPoolContract.self.event('Deposit');
      contractWithdrawEvent = lendingPoolContract.self.event('Withdraw');
      contractBorrowEvent = lendingPoolContract.self.event('Borrow');
      contractRepayEvent = lendingPoolContract.self.event('Repay');
    } catch (e) {
      log.e('error setting up contracts: $e');
    }
  }

  /// get Aave reserve list.
  ///
  Future<List<EthereumAddress>> getAaveReserveList() async {
    log.i('getting reserve list');
    try {
      List<EthereumAddress> reserveList =
          await lendingPoolContract.getReservesList();

      return reserveList;
    } catch (e) {
      log.e('error getting aave reserve list: $e');
      throw 'Could not get aave reserve list.';
    }
  }

  /// extract user form borrow event
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

  /// query events by contract, filtering by block and address
  queryEventsByContract() async {
    log.i('querying block');
    try {
      /// create filter
      final _filterOptions = FilterOptions(
          fromBlock: BlockNum.exact(27713385),
          toBlock: BlockNum.exact(27713385),
          address: _config.lendingPoolProxyContractAddress);

      /// query block for matching logs
      List<FilterEvent> logs = await _web3Client.getLogs(_filterOptions);
      log.d('Data: ${logs[0].data} \n Topics: ${logs[0].topics}');
    } catch (e) {
      log.e('error querying events by contract: $e');
    }
  }

  /// query borrow event
  Future<List<AaveBorrowEvent>> queryBorrowEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying borrow event | fromBlock: $fromBlock, toBlock: $toBlock');
    try {
      /// create filter
      FilterOptions _filter = FilterOptions(
          address: _config.lendingPoolProxyContractAddress,
          fromBlock: fromBlock != null
              ? BlockNum.exact(fromBlock)
              : BlockNum.current(),
          toBlock:
              toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
          topics: [
            [_config.encodedBorrowEventTopic]
          ]);
      List<FilterEvent> _borrowEvent = await _web3Client.getLogs(_filter);

      log.v('borrow event: $_borrowEvent');
      return _borrowEvent
          .map((e) => _parseEventToAaveBorrowEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying borrow event: $e');
      throw 'Could not get borrow events';
    }
  }

  /// query deposit event

  Future<List<AaveDepositEvent>> queryDepositEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying deposit event');
    try {
      /// create filter
      FilterOptions _filter = FilterOptions(
          address: _config.lendingPoolProxyContractAddress,
          fromBlock: fromBlock != null
              ? BlockNum.exact(fromBlock)
              : BlockNum.current(),
          toBlock:
              toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
          topics: [
            [_config.encodedDepositEventTopic]
          ]);
      List<FilterEvent> _depositEvent = await _web3Client.getLogs(_filter);

      return _depositEvent
          .map((e) => _parseEventToAaveDepositEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying deposit event: $e');
      throw ' Could no get deposit events';
    }
  }

  /// query repay event
  Future<List<AaveRepayEvent>> queryRepayEvent(
      {int? fromBlock, int? toBlock}) async {
    log.i('querying repay event');
    try {
      /// create filter
      FilterOptions _filter = FilterOptions(
          address: _config.lendingPoolProxyContractAddress,
          fromBlock: fromBlock != null
              ? BlockNum.exact(fromBlock)
              : BlockNum.current(),
          toBlock:
              toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
          topics: [
            [_config.encodedRepayEventTopic]
          ]);
      List<FilterEvent> _repayEvent = await _web3Client.getLogs(_filter);

      return _repayEvent
          .map((e) => _parseEventToAaveRepayEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying repay event: $e');
      throw 'Could not get repay event';
    }
  }

  /// query withdraw event
  Future<List<AaveWithdrawEvent>> queryWithdrawEvent(
      {int? fromBlock, int? toBlock}) async {
    log.d('querying repay event');
    try {
      /// create filter
      FilterOptions _filter = FilterOptions(
          address: _config.lendingPoolProxyContractAddress,
          fromBlock: fromBlock != null
              ? BlockNum.exact(fromBlock)
              : BlockNum.current(),
          toBlock:
              toBlock != null ? BlockNum.exact(toBlock) : BlockNum.current(),
          topics: [
            [_config.encodedWithdrawEventTopic]
          ]);
      List<FilterEvent> _withdrawEvent = await _web3Client.getLogs(_filter);

      return _withdrawEvent
          .map((e) => _parseEventToAaveWithdrawEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying withdraw event: $e');
      throw 'Could not get withdraw event';
    }
  }

  /// get user account data from Aave
  Future<List<Map<String, dynamic>>> getUserAccountData(
      {required List<String> userList}) async {
    try {
      if (userList.isEmpty) {
        throw 'no user given';
      }
      log.i(
          'getting user account data of ${userList.length} users.\n Please wait...');
      List<Map<String, dynamic>> _aaveUserList = [];

      /// iterate throught the list of users and get their user account data.
      for (var user in userList) {
        EthereumAddress _userAddress = EthereumAddress.fromHex(user);
        final GetUserAccountData userAccountData =
            await lendingPoolContract.getUserAccountData(_userAddress);

        /// only keep users with a health factor below [_config.focusHealthFactor]
        if (userAccountData.healthFactor.toDouble() <
            _config.focusHealthFactor) {
          log.d('found accounts with low Health factor');

          AaveUserReserveData _userReserveData =
              await getAaveUserReserveData(userAddress: _userAddress);
          AaveUserAccountData _userData = _parseUserAccountData(
              userAddress: _userAddress,
              userAccountData: userAccountData,
              userReserveData: _userReserveData);
          log.d('user data in json: ${_userData.toJson()}');
          // String jsonEncodedUserData = jsonEncode(_userData);
          _aaveUserList.add(_userData.toJson());

          //TODO: upload to each ner to db.

          _store.replaceUserData(_userData.toJson());
        }
      }
      log.i('Found ${_aaveUserList.length} users at risk of liquidation.');
      return _aaveUserList;
    } catch (e) {
      log.e('error getting user account data: $e');
      throw 'Could not get user account data';
    }
  }

  /// get user configuration from aave
  Future<List> _getAaveUserConfig(EthereumAddress aaveUser) async {
    log.v('getting user config | aaveUser: $aaveUser');
    try {
      final rawUserConfigList =
          await lendingPoolContract.getUserConfiguration(aaveUser);

      BigInt userConfig = rawUserConfigList.first;
      log.d('user config: $userConfig');
      List _userReserveList = [];

      /// convert result to binary string
      String userConfigBinary = userConfig.toRadixString(2);

      /// check to see if length is even.
      /// this is needed before splitting into binary pairs.
      /// pad beginning of string with ["00"] if odd.
      if (userConfigBinary.length % 2 != 0) {
        log.v('oldR: $userConfigBinary');
        userConfigBinary =
            userConfigBinary.padLeft(userConfigBinary.length + 1, '0');
      }

      /// verify that the lenght of the reserves list is the same as the number
      /// of pairs. If not, pad at beginning of string  with ["0"].
      int numberOfPairs = (userConfigBinary.length / 2).round();

      if (numberOfPairs != aaveReserveList.length) {
        int diff = (aaveReserveList.length - numberOfPairs).round();

        int padLength = (numberOfPairs + diff) * 2;

        userConfigBinary = userConfigBinary.padLeft(padLength, '0');
        log.v('newR: $userConfigBinary ${userConfigBinary.length}');
      }

      /// split list into list of binary pairs
      final pattern = RegExp(r'(..)');
      final patternMatch = pattern.allMatches(userConfigBinary);

      for (var element in patternMatch) {
        /// add to a list
        _userReserveList.add(element.group(0));
      }

      /// flip the resulting list to match aave reserve list ordering
      _userReserveList = _userReserveList.reversed.toList();
      log.d(
          'userReserveList: $_userReserveList ; lengthRatio: ${_userReserveList.length}:${aaveReserveList.length}');

      return _userReserveList;
    } catch (e) {
      log.e('error getting user configuration: $e');
      throw 'could not get user configurations';
    }
  }

  /// get user reserve data
  Future<AaveUserReserveData> getAaveUserReserveData({
    required EthereumAddress userAddress,
  }) async {
    log.d('getAaveUserReserveData | user address: $userAddress');
    try {
      List _userConfig = await _getAaveUserConfig(userAddress);
      Map<String, List> _userReserves = _mixAndMatch(_userConfig);
      AaveUserReserveData _aaveUserReserveData = AaveUserReserveData(
        collateral: {},
        stableDebt: {},
        variableDebt: {},
      );

      for (final collateral in _userReserves['collateral']!) {
        GetUserReserveData userReserveData =
            await protocolDataProviderContract.getUserReserveData(
          EthereumAddress.fromHex(collateral),
          userAddress,
        );

        /// get collateral
        _aaveUserReserveData.collateral.update(
          collateral,
          (value) => userReserveData.currentATokenBalance.toDouble(),
          ifAbsent: () => userReserveData.currentATokenBalance.toDouble(),
        );
      }
      for (final debt in _userReserves['debt']!) {
        GetUserReserveData userReserveData =
            await protocolDataProviderContract.getUserReserveData(
          EthereumAddress.fromHex(debt),
          userAddress,
        );

        /// get variable debt
        _aaveUserReserveData.variableDebt.update(
          debt,
          (value) => userReserveData.currentVariableDebt.toDouble(),
          ifAbsent: () => userReserveData.currentVariableDebt.toDouble(),
        );

        /// get stabel debt
        _aaveUserReserveData.stableDebt.update(
          debt,
          (value) => userReserveData.currentStableDebt.toDouble(),
          ifAbsent: () => userReserveData.currentStableDebt.toDouble(),
        );
      }
      log.d('final user reserves: $_aaveUserReserveData');
      return _aaveUserReserveData;
    } catch (e) {
      log.e('error getting user reserve data: $e');
      throw 'error getting user reserve data';
    }
  }

  ///listen for borrow events
  _listenForBorrowEvents() {
    log.i('listenning for borrow event');

    lendingPoolContract.borrowEvents().listen((_borrow) {
      log.d('new borrow event: $_borrow');
      _parseEventToAaveBorrowEvent(borrow: _borrow);
    });
  }

  /// listen for deposit events
  _listenForDepositEvent() {
    log.i('listenning for deposit event');

    lendingPoolContract.depositEvents().listen((_deposit) {
      log.d('new deposit event: $_deposit');

      _parseEventToAaveDepositEvent(deposit: _deposit);
    });
  }

  /// listenf for repay event
  _listenForRepayEvent() {
    log.i('listenning for repay event');

    lendingPoolContract.repayEvents().listen((_repay) {
      log.d('new repay event: $_repay');
      _parseEventToAaveRepayEvent(repay: _repay);
    });
  }

  /// listen for withdraw event
  _listenForWithdrawEvent() {
    log.i('listenning for withdraw event');
    lendingPoolContract.withdrawEvents().listen((_withdraw) {
      log.d('new withdraw event: $_withdraw');
      _parseEventToAaveWithdrawEvent(withdraw: _withdraw);
    });
  }

  /// listen for liquidation call events
  /// TODO:

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

// parse deposit event data and topics
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
  ///
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

  /// Parse withdraw event
  ///
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

  /// parse user data
  AaveUserAccountData _parseUserAccountData({
    required EthereumAddress userAddress,
    required GetUserAccountData userAccountData,
    required AaveUserReserveData userReserveData,
  }) {
    log.v('parsing user data');

    final parsedUserAccountData = AaveUserAccountData(
      userAddress: userAddress.toString(),
      totalCollateralEth: userAccountData.totalCollateralETH.toDouble(),
      collateralReserve: userReserveData.collateral,
      totalDebtETH: userAccountData.totalDebtETH.toDouble(),
      stableDebtReserve: userReserveData.stableDebt,
      variableDebtReserve: userReserveData.variableDebt,
      availableBorrowsETH: userAccountData.availableBorrowsETH.toDouble(),
      currentLiquidationThreshold:
          userAccountData.currentLiquidationThreshold.toDouble(),
      ltv: userAccountData.ltv.toDouble(),
      healthFactor: userAccountData.healthFactor.toDouble(),
    );

    return parsedUserAccountData;
  }

  // /// write user data to file
  // _writeToStorage(String contents) async {
  //   log.i('writing to storage');
  //   try {
  //     if (await File(_config.storageFilename).exists()) {
  //       log.v('appending to storage file');
  //       await File(_config.storageFilename)
  //           .writeAsString(',$contents', mode: FileMode.append);
  //     } else {
  //       log.v('creating new storage file');
  //       await File(_config.storageFilename)
  //           .writeAsString(contents, mode: FileMode.append);
  //     }
  //   } catch (e) {
  //     log.e('error writing to file: $e');
  //   }
  // }

  /// format user data to write to file
  Map<String, List> _mixAndMatch(List pairList) {
    log.v('mix and match');

    /// for each reserve pair in the list,
    /// if the reserve pair is "10"
    List<String> collateralReserve = [];
    List<String> debtReserve = [];
    for (var i = 0; i < aaveReserveList.length; i++) {
      if (pairList[i] == '10') {
        log.v('adding ${aaveReserveList[i]}to collateral');

        /// add reserve address to colateral list
        collateralReserve.add(aaveReserveList[i].toString());
      } else if (pairList[i] == '01') {
        log.v('adding ${aaveReserveList[1]} to debt');

        /// add reserve address to debt list
        debtReserve.add(aaveReserveList[i].toString());
      } else if (pairList[i] == '11') {
        /// add reserve address to collaterral and debt list.
        collateralReserve.add(aaveReserveList[i].toString());
        debtReserve.add(aaveReserveList[i].toString());
      }
    }
    return {'collateral': collateralReserve, 'debt': debtReserve};
  }
}
