// ignore_for_file: avoid_log.

import 'dart:convert';
import 'dart:io';

import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_withdraw_event.dart';
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

  Web3Service() {
    _config = Config();
    _initWeb3Client();
  }

  bool _isListenning = false;
  bool get isReady => _isListenning;

  late Web3Client _web3Client;
  late int _chainId;
  final Client _httpClient = Client();

  late CredentialsWithKnownAddress credentials;

  // late ContractAbi _proxyContractAbi;
  // late ContractAbi _lendingPoolContractAbi;

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
  List<String> userFromEvents = [];
  List<EthereumAddress> aaveReserveList = [];

  _initWeb3Client() async {
    await _connectViaRpcApi();
    _getCredentials();
    await _setupContracts();
    aaveReserveList = await getAaveReserveList();

    queriedBorrowEvent = await queryBorrowEvent(fromBlock: 27858000);
    userFromEvents = _extractUserFromBorrowEvent(queriedBorrowEvent);
    // queriedDepositEvent = await queryDepositEvent(fromBlock: 27647000);
    // queriedRepayEvent = await queryRepayEvent(fromBlock: 27815000);

    List<String> userDataList =
        await getUserAccountData(userList: userFromEvents);

    _writeToStorage(userDataList.toString());
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

  // /// get ABI
  // ///
  // Future<void> _getAbi() async {
  //   try {
  //     /// read proxy abi
  //     // final _proxyAbiCode = await _config.proxyAbiFile.readAsString();
  //     // _proxyContractAbi =
  //     //     ContractAbi.fromJson(_proxyAbiCode, _config.proxyContractName);
  //   } catch (e) {
  //     log.e('error getting abi: $e');
  //   }
  // }

  /// setup contracts

  _setupContracts() async {
    log.i('setting up contract');
    try {
      // await _getAbi();

      // proxyContract = DeployedContract(
      //   _proxyContractAbi,
      //   _config.lendingPoolProxyContractAddress,
      // );

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
      return [];
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
          fromBlock: fromBlock != null ? BlockNum.exact(fromBlock) : null,
          toBlock: toBlock != null ? BlockNum.exact(toBlock) : null,
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
      return [];
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
          fromBlock: fromBlock != null ? BlockNum.exact(fromBlock) : null,
          toBlock: toBlock != null ? BlockNum.exact(toBlock) : null,
          topics: [
            [_config.encodedDepositEventTopic]
          ]);
      List<FilterEvent> _depositEvent = await _web3Client.getLogs(_filter);

      return _depositEvent
          .map((e) => _parseEventToAaveDepositEvent(filterEvent: e))
          .toList();
    } catch (e) {
      log.e('error querying deposit event: $e');
      return [];
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
          fromBlock: fromBlock != null ? BlockNum.exact(fromBlock) : null,
          toBlock: toBlock != null ? BlockNum.exact(toBlock) : null,
          topics: [
            [_config.encodedRepayEventTopic]
          ]);
      List<FilterEvent> _repayEvent = await _web3Client.getLogs(_filter);

      return _repayEvent.map((e) => _parseEventToAaveRepayEvent(e)).toList();
    } catch (e) {
      log.e('error querying repay event: $e');
      return [];
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
          fromBlock: fromBlock != null ? BlockNum.exact(fromBlock) : null,
          toBlock: toBlock != null ? BlockNum.exact(toBlock) : null,
          topics: [
            [_config.encodedWithdrawEventTopic]
          ]);
      List<FilterEvent> _withdrawEvent = await _web3Client.getLogs(_filter);

      return _withdrawEvent
          .map((e) => _parseEventToAaveWithdrawEvent(e))
          .toList();
    } catch (e) {
      log.e('error querying withdraw event: $e');
      return [];
    }
  }

  /// get user account data from Aave
  Future<List<String>> getUserAccountData(
      {required List<String> userList}) async {
    try {
      if (userList.isEmpty) {
        throw 'no user given';
      }
      log.i('getting user account data of ${userList.length} users');
      List<String> _aaveUserList = [];

      /// iterate throught the list of users and get their user account data.
      for (var user in userList) {
        EthereumAddress? _userAddress;
        List _userConfig = [];
        _userAddress = EthereumAddress.fromHex(user);
        final GetUserAccountData userAccountData =
            await lendingPoolContract.getUserAccountData(_userAddress);

        /// only keep users with a health factor below [_config.focusHealthFactor]
        if (userAccountData.healthFactor.toDouble() <
            _config.focusHealthFactor) {
          log.d('found accounts with low Health factor');

          _userConfig = await _getAaveUserConfig(_userAddress);
          AaveUserAccountData _userData = _parseUserAccountData(
            userAddress: _userAddress,
            userAccountData: userAccountData,
            userConfig: _userConfig,
          );
          await getAaveUserReserveData(_userData);

          String jsonEncodedUserData = jsonEncode(_userData);
          _aaveUserList.add(jsonEncodedUserData);
        }
      }
      log.i('Only ${_aaveUserList.length} users at risk of liquidation.');
      return _aaveUserList;
    } catch (e) {
      log.e('error getting user account data: $e');
      return [];
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
      return [];
    }
  }

  getAaveUserReserveData(AaveUserAccountData userData) async {
    log.v('getAaveUserReserveData | userData: $userData');
    try {
      late var userReserveData;
      for (final collateral in userData.collateralReserve) {
        userReserveData = await protocolDataProviderContract.getUserReserveData(
            EthereumAddress.fromHex(collateral),
            EthereumAddress.fromHex(userData.userAddress));
      }
    } catch (e) {
      log.e('error getting user reserve data: $e');
    }
  }

  ///listen for borrow events
  _listenForBorrowEvents() {
    log.i('listenning for borrow event');

    lendingPoolContract.borrowEvents().listen((borrow) {
      log.d('new borrow event: $borrow');
      _parseEventToAaveBorrowEvent(borrow: borrow);
    });
  }

  /// listen for deposit events
  _listenForDepositEvent() {
    log.i('listenning for deposit event');
    // final options = FilterOptions(
    //     address: _config.lendingPoolProxyContractAddress,
    //     topics: [
    //       [_config.encodedDepositEventTopic]
    //     ]);
    lendingPoolContract.depositEvents().listen((deposit) {
      log.d('new deposit event: $deposit');

      _parseEventToAaveDepositEvent(deposit: deposit);
    });
  }

  /// listenf for repay event
  _listenForRepayEvent() {
    log.i('listenning for repay event');
    final options = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        topics: [
          [_config.encodedRepayEventTopic]
        ]);
    _web3Client.events(options).listen((event) {
      log.d('new repay event');
      _parseEventToAaveRepayEvent(event);
    });
  }

  /// listen for withdraw event
  _listenForWithdrawEvent() {
    // TODO: implement
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
  AaveRepayEvent _parseEventToAaveRepayEvent(FilterEvent _repayEvent) {
    log.v('parsing repay event');
    final List _decodedResult = contractRepayEvent.decodeResults(
        _repayEvent.topics!, _repayEvent.data!);

    final parsedRepayEvent = AaveRepayEvent(
      reserve: _decodedResult[0].toString(),
      userAddress: _decodedResult[1].toString(),
      onBehalfOf: _decodedResult[2].toString(),
      amount: double.parse(_decodedResult[3].toString()),
    );

    return parsedRepayEvent;
  }

  /// Parse withdraw event
  ///
  AaveWithdrawEvent _parseEventToAaveWithdrawEvent(FilterEvent _withdrawEvent) {
    log.v('parsing withdraw event');
    List _decodedResult;

    _decodedResult = contractWithdrawEvent.decodeResults(
        _withdrawEvent.topics!, _withdrawEvent.data!);

    log.d('decoded withdraw event: $_decodedResult');
    final parsedWithdrawEvent = AaveWithdrawEvent(
      reserve: _decodedResult[0].toString(),
      userAddress: _decodedResult[1].toString(),
      to: _decodedResult[2].toString(),
      amount: double.parse(_decodedResult[3].toString()),
    );
    log.d(parsedWithdrawEvent);
    return parsedWithdrawEvent;
  }

  /// parse user data
  AaveUserAccountData _parseUserAccountData({
    required EthereumAddress userAddress,
    required GetUserAccountData userAccountData,
    required List userConfig,
  }) {
    log.v('parsing user data');
    List<List<String>> _userReserves = _mixAndMatch(userConfig);
    final parsedUserAccountData = AaveUserAccountData(
      userAddress: userAddress.toString(),
      totalCollateralEth: userAccountData.totalCollateralETH.toDouble(),
      collateralReserve: _userReserves.first,
      totalDebtETH: userAccountData.totalDebtETH.toDouble(),
      debtReserve: _userReserves.last,
      availableBorrowsETH: userAccountData.availableBorrowsETH.toDouble(),
      currentLiquidationThreshold:
          userAccountData.currentLiquidationThreshold.toDouble(),
      ltv: userAccountData.ltv.toDouble(),
      healthFactor: userAccountData.healthFactor.toDouble(),
    );

    return parsedUserAccountData;
  }

  /// parse user reserve data
  /// TODO:

  /// write user data to file
  _writeToStorage(String contents) async {
    log.i('writing to storage');
    try {
      if (await File(_config.storageFilename).exists()) {
        log.v('appending to storage file');
        await File(_config.storageFilename)
            .writeAsString(',$contents', mode: FileMode.append);
      } else {
        log.v('creating new storage file');
        await File(_config.storageFilename)
            .writeAsString(contents, mode: FileMode.append);
      }
    } catch (e) {
      log.e('error writing to file: $e');
    }
  }

  /// format user data to write to file
  List<List<String>> _mixAndMatch(List pairList) {
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
    return [collateralReserve, debtReserve];
  }
}
