// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/enums/event_enums.dart';
import 'package:aave_liquidator/model/aave_withdraw_event.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';

import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_deposit_event.dart';
import 'package:aave_liquidator/model/aave_repay_event.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:web3dart/web3dart.dart';

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

  late ContractAbi _lendingPoolContractAbi;
  late ContractAbi _proxyContractAbi;

  late DeployedContract lendingPoolContract;
  late DeployedContract proxyContract;

  late ContractEvent contractDepositEvent;
  late ContractEvent contractWithdrawEvent;
  late ContractEvent contractBorrowEvent;
  late ContractEvent contractRepayEvent;
  late ContractFunction getUserAccountDataFunction;
  late ContractFunction getUserConfiguration;
  late ContractFunction getReserveList;

  late List<AaveBorrowEvent> queriedBorrowEvent;
  late List<AaveDepositEvent> queriedDepositEvent;
  late List<AaveRepayEvent> queriedRepayEvent;
  List<String> userFromEvents = [];
  List aaveReserveList = [];

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
    print('disposing web3');
  }

  /// Connect to blockchain using address in localhost
  Future<void> _connectViaRpcApi() async {
    print('connecting using Infura');
    _web3Client = Web3Client(_config.kovanApiUrl, _httpClient);
    _chainId = await _web3Client.getNetworkId();
    print('current chainID: $_chainId');
    _isListenning = await _web3Client.isListeningForNetwork();
    print('web3Client is listening: $_isListenning');
  }

  /// Connect wallet
  _getCredentials() {
    print('getting credentials');
    credentials = EthPrivateKey.fromHex(env['WALLET_PRIVATE_KEY']!);
  }

  getCurrentBalance() async {
    print('getting balance');
    final balance = await _web3Client.getBalance(credentials.address);
    print(balance);
  }

  /// get ABI
  Future<void> _getAbi() async {
    try {
      final _proxyAbiCode = await _config.proxyAbiFile.readAsString();
      _proxyContractAbi = ContractAbi.fromJson(
          _proxyAbiCode, 'InitializableImmutableAdminUpgradeabilityProxy');

      final _lendingPoolAbiCode =
          await _config.lendingPoolAbiFile.readAsString();
      _lendingPoolContractAbi =
          ContractAbi.fromJson(_lendingPoolAbiCode, 'LendingPool');
    } catch (e) {
      print('error getting abi: $e');
    }
  }

  /// setup contracts
  _setupContracts() async {
    print('setting up contract');
    try {
      await _getAbi();

      proxyContract = DeployedContract(
        _proxyContractAbi,
        _config.lendingPoolProxyContractAddress,
      );
      lendingPoolContract = DeployedContract(
        _lendingPoolContractAbi,
        _config.lendingPoolContractAddress,
      );

      /// setup contract events
      contractDepositEvent = lendingPoolContract.event('Deposit');
      contractWithdrawEvent = lendingPoolContract.event('Withdraw');
      contractBorrowEvent = lendingPoolContract.event('Borrow');
      contractRepayEvent = lendingPoolContract.event('Repay');

      /// setup contract functions
      getUserAccountDataFunction =
          lendingPoolContract.function('getUserAccountData');
      getUserConfiguration =
          lendingPoolContract.function('getUserConfiguration');
      getReserveList = lendingPoolContract.function('getReservesList');
    } catch (e) {
      print('error setting up contracts: $e');
    }
  }

  /// get Aave reserve list.
  ///
  Future<List> getAaveReserveList() async {
    print('getting reserve list');
    try {
      List reserveList = await _web3Client
          .call(contract: proxyContract, function: getReserveList, params: []);
      reserveList = reserveList.first;

      return reserveList;
    } catch (e) {
      print('error getting aave reserve list: $e');
      return [];
    }
  }

  /// extract user form borrow event
  List<String> _extractUserFromBorrowEvent(List<AaveBorrowEvent> eventsList) {
    print('extracting user address from borrow event');
    if (eventsList.isNotEmpty) {
      List<String> _userList = [];
      for (var event in eventsList) {
        if (!_userList.contains(event.onBehalfOf)) {
          _userList.add(event.onBehalfOf);
          // print('adding ${event.onBehalfOf} to list');

        }
      }

      return _userList;
    } else {
      print('events list was null');
      return [];
    }
  }

  /// query events by contract, filtering by block and address
  queryEventsByContract() async {
    print('querying block');
    try {
      /// create filter
      final _filterOptions = FilterOptions(
          fromBlock: BlockNum.exact(27713385),
          toBlock: BlockNum.exact(27713385),
          address: _config.lendingPoolProxyContractAddress);

      /// query block for matching logs
      List<FilterEvent> logs = await _web3Client.getLogs(_filterOptions);
      print('Data: ${logs[0].data} \n Topics: ${logs[0].topics}');
    } catch (e) {
      print('error querying events by contract: $e');
    }
  }

  /// query borrow event
  Future<List<AaveBorrowEvent>> queryBorrowEvent(
      {int? fromBlock, int? toBlock}) async {
    print('querying borrow event');
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
      // print('borrow event: $_borrowEvent');
      return _borrowEvent.map((e) => _parseEventToAaveBorrowEvent(e)).toList();
    } catch (e) {
      print('error querying borrow event: $e');
      return [];
    }
  }

  /// query deposit event

  Future<List<AaveDepositEvent>> queryDepositEvent(
      {int? fromBlock, int? toBlock}) async {
    print('querying deposit event');
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
          .map((e) => _parseEventToAaveDepositEvent(e))
          .toList();
    } catch (e) {
      print('error querying deposit event: $e');
      return [];
    }
  }

  /// query repay event
  Future<List<AaveRepayEvent>> queryRepayEvent(
      {int? fromBlock, int? toBlock}) async {
    print('querying repay event');
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
      print('error querying repay event: $e');
      return [];
    }
  }

  /// query withdraw event
  Future<List<AaveWithdrawEvent>> queryWithdrawEvent(
      {int? fromBlock, int? toBlock}) async {
    print('querying repay event');
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
      print('error querying withdraw event: $e');
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
      print('getting user account data of ${userList.length} users');
      List<String> _aaveUserList = [];

      /// iterate throught the list of users and get their user account data.
      for (var user in userList) {
        EthereumAddress? _userAddress;
        List _userConfig = [];
        _userAddress = EthereumAddress.fromHex(user);
        final List userAccountData = await _web3Client.call(
          contract: proxyContract,
          function: getUserAccountDataFunction,
          params: [_userAddress],
        );

        /// only keep users with a health factor below [_config.focusHealthFactor]
        if (double.parse(userAccountData[5].toString()) <
            _config.focusHealthFactor) {
          print('found accounts with low Health factor');

          _userConfig = await _getAaveUserConfig(_userAddress);
          AaveUserAccountData _userData = _parseUserAccountData(
            userAddress: _userAddress,
            userAccountData: userAccountData,
            userConfig: _userConfig,
          );

          String jsonEncodedUserData = jsonEncode(_userData);
          _aaveUserList.add(jsonEncodedUserData);
        }
      }

      return _aaveUserList;
    } catch (e) {
      print('error getting user account data: $e');
      return [];
    }
  }

  /// get user configuration from aave
  Future<List> _getAaveUserConfig(EthereumAddress aaveUser) async {
    print('getting user config');
    try {
      final rawUserConfigList = await _web3Client.call(
          contract: proxyContract,
          function: getUserConfiguration,
          params: [aaveUser]);
      List userConfigList = rawUserConfigList.first;
      BigInt userConfig = userConfigList.first;
      List _userReserveList = [];

      /// convert result to binary string
      String userConfigBinary = userConfig.toRadixString(2);

      /// check to see if length is even.
      /// this is needed before splitting into binary pairs.
      /// pad beginning of string with ["00"] if odd.
      if (userConfigBinary.length % 2 != 0) {
        print('oldR: $userConfigBinary');
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
        print('newR: $userConfigBinary ${userConfigBinary.length}');
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
      print(
          'userReserveList: $_userReserveList ; lengthRatio: ${_userReserveList.length}:${aaveReserveList.length}');

      return _userReserveList;
    } catch (e) {
      print('error getting user configuration: $e');
      return [];
    }
  }

//listen for borrow events
  _listenForBorrowEvents() {
    print('listenning for borrow event');
    final options = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        topics: [
          [_config.encodedBorrowEventTopic]
        ]);
    _web3Client.events(options).listen((event) {
      print('new borrow event: $event');
      _parseEventToAaveBorrowEvent(event);
    });
  }

// listen for deposit events
  _listenForDepositEvent() {
    print('listenning for deposit event');
    final options = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        topics: [
          [_config.encodedDepositEventTopic]
        ]);
    _web3Client.events(options).listen((event) {
      print('new deposit event: $event');

      _parseEventToAaveDepositEvent(event);
    });
  }

  _listenForRepayEvent() {
    print('listenning for repay event');
    final options = FilterOptions(
        address: _config.lendingPoolProxyContractAddress,
        topics: [
          [_config.encodedRepayEventTopic]
        ]);
    _web3Client.events(options).listen((event) {
      print('new repay event');
      _parseEventToAaveRepayEvent(event);
    });
  }

  /// listen for withdraw event
  _listenForWithdrawEvent() {
    // TODO: implement
  }

  /// parse borrow event data and topics
  AaveBorrowEvent _parseEventToAaveBorrowEvent(FilterEvent _borrowEvent) {
    final List _decodedResult = contractBorrowEvent.decodeResults(
        _borrowEvent.topics!, _borrowEvent.data!);

    final parsedBorrowEvent = AaveBorrowEvent(
      userAddress: _decodedResult[1].toString(),
      onBehalfOf: _decodedResult[2].toString(),
      reserve: _decodedResult[0].toString(),
      amount: double.parse(_decodedResult[3].toString()),
      borrowRateMode: double.parse(_decodedResult[4].toString()),
      borrowRate: double.parse(_decodedResult[5].toString()),
    );

    return parsedBorrowEvent;
  }

// parse deposit event data and topics
  AaveDepositEvent _parseEventToAaveDepositEvent(FilterEvent _depositEvent) {
    // print('decoding deposit event');
    final List _decodedResult = contractDepositEvent.decodeResults(
        _depositEvent.topics!, _depositEvent.data!);

    final parsedDepositEvent = AaveDepositEvent(
      reserve: _decodedResult[0].toString(),
      userAddress: _decodedResult[1].toString(),
      onBehalfOf: _decodedResult[2].toString(),
      amount: double.parse(_decodedResult[3].toString()),
    );

    return parsedDepositEvent;
  }

  /// Parse repay event
  ///
  AaveRepayEvent _parseEventToAaveRepayEvent(FilterEvent _repayEvent) {
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
  AaveWithdrawEvent _parseEventToAaveWithdrawEvent(
      FilterEvent _withdrawEvent) {
    List _decodedResult;

    _decodedResult = contractWithdrawEvent.decodeResults(
        _withdrawEvent.topics!, _withdrawEvent.data!);

    // print('decoded withdraw event: $_decodedResult');
    final parsedWithdrawEvent = AaveWithdrawEvent(
      reserve: _decodedResult[0].toString(),
      userAddress: _decodedResult[1].toString(),
      to: _decodedResult[2].toString(),
      amount: double.parse(_decodedResult[3].toString()),
    );
    // print(parsedWithdrawEvent);
    return parsedWithdrawEvent;
  }

  /// parse user data

  AaveUserAccountData _parseUserAccountData({
    required EthereumAddress userAddress,
    required List userAccountData,
    required List userConfig,
  }) {
    print('parsing user data');
    List<List<String>> _userReserves = _mixAndMatch(userConfig);
    final parsedUserAccountData = AaveUserAccountData(
      userAddress: userAddress.toString(),
      totalCollateralEth: double.parse(userAccountData[0].toString()),
      collateralReserve: _userReserves.first,
      totalDebtETH: double.parse(userAccountData[1].toString()),
      debtReserve: _userReserves.last,
      availableBorrowsETH: double.parse(userAccountData[2].toString()),
      currentLiquidationThreshold: double.parse(userAccountData[3].toString()),
      ltv: double.parse(userAccountData[4].toString()),
      healthFactor: double.parse(userAccountData[5].toString()),
    );

    return parsedUserAccountData;
  }

  /// write user data to file
  _writeToStorage(String contents) async {
    try {
      await File(_config.storageFilename)
          .writeAsString(contents, mode: FileMode.append);
    } catch (e) {
      print('error writing to file: $e');
    }
  }

  /// format user data to write to file
  List<List<String>> _mixAndMatch(List pairList) {
    print('mix and match');

    /// for each reserve pair in the list,
    /// if the reserve pair is "10"
    List<String> collateralReserve = [];
    List<String> debtReserve = [];
    for (var i = 0; i < aaveReserveList.length; i++) {
      if (pairList[i] == '10') {
        // print('adding ${aaveReserveList[i]}to collateral');

        /// add reserve address to colateral list
        collateralReserve.add(aaveReserveList[i].toString());
      } else if (pairList[i] == '01') {
        // print('adding ${aaveReserveList[1]} to debt');

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
