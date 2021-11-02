import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveUserLiquidator');

class AaveUserLiquidator {
  late Web3Service _web3service;
  late MongodService _store;
  late Config _config;

  AaveUserLiquidator(Web3Service web3, Config config, MongodService mongod) {
    _web3service = web3;
  }

  late List aaveReserveList; // TODO: fetch from db.

  /// get reservelist from db.

  /// Get user account data from Aave.
  Future<List<Map<String, dynamic>>> getUserAccountData(
      {required List<String> userList}) async {
    try {
      if (userList.isEmpty) {
        throw 'no user given';
      }
      log.i(
          'getting user account data of ${userList.length} users.\n Please wait...');
      List<Map<String, dynamic>> _aaveUserList = [];

      /// Iterate throught the list of users and get their user account data.
      for (var user in userList) {
        EthereumAddress _userAddress = EthereumAddress.fromHex(user);
        final GetUserAccountData userAccountData = await _web3service
            .lendingPoolContract
            .getUserAccountData(_userAddress);

        /// Only keep users with a health factor below [_config.focusHealthFactor].
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

          //TODO: upload to each user to db?

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

  /// Get user reserve data.
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
            await _web3service.protocolDataProviderContract.getUserReserveData(
          EthereumAddress.fromHex(collateral),
          userAddress,
        );

        /// Get user collateral.
        _aaveUserReserveData.collateral.update(
          collateral,
          (value) => userReserveData.currentATokenBalance.toDouble(),
          ifAbsent: () => userReserveData.currentATokenBalance.toDouble(),
        );
      }
      for (final debt in _userReserves['debt']!) {
        GetUserReserveData userReserveData =
            await _web3service.protocolDataProviderContract.getUserReserveData(
          EthereumAddress.fromHex(debt),
          userAddress,
        );

        /// Get user variable debt.
        _aaveUserReserveData.variableDebt.update(
          debt,
          (value) => userReserveData.currentVariableDebt.toDouble(),
          ifAbsent: () => userReserveData.currentVariableDebt.toDouble(),
        );

        /// Get user stable debt.
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

  /// Get user configuration from aave.
  Future<List> _getAaveUserConfig(EthereumAddress aaveUser) async {
    log.v('getting user config | aaveUser: $aaveUser');
    try {
      final rawUserConfigList =
          await _web3service.lendingPoolContract.getUserConfiguration(aaveUser);

      BigInt userConfig = rawUserConfigList.first;
      log.d('user config: $userConfig');
      List _userReserveList = [];

      /// Convert result to binary string.
      String userConfigBinary = userConfig.toRadixString(2);

      /// Check to see if length is even.
      /// This is needed before splitting into binary pairs.
      /// Pad beginning of string with ["00"] if odd.
      if (userConfigBinary.length % 2 != 0) {
        log.v('oldR: $userConfigBinary');
        userConfigBinary =
            userConfigBinary.padLeft(userConfigBinary.length + 1, '0');
      }

      /// Verify that the lenght of the reserves list is the same as the number
      /// of pairs. If not, pad at beginning of string  with ["0"].
      int numberOfPairs = (userConfigBinary.length / 2).round();

      if (numberOfPairs != aaveReserveList.length) {
        int diff = (aaveReserveList.length - numberOfPairs).round();

        int padLength = (numberOfPairs + diff) * 2;

        userConfigBinary = userConfigBinary.padLeft(padLength, '0');
        log.v('newR: $userConfigBinary ${userConfigBinary.length}');
      }

      /// Split list into list of binary pairs.
      final pattern = RegExp(r'(..)');
      final patternMatch = pattern.allMatches(userConfigBinary);

      for (var element in patternMatch) {
        /// Add to a list.
        _userReserveList.add(element.group(0));
      }

      /// Flip the resulting list to match aave reserve list ordering.
      _userReserveList = _userReserveList.reversed.toList();
      log.d(
          'userReserveList: $_userReserveList ; lengthRatio: ${_userReserveList.length}:${aaveReserveList.length}');

      return _userReserveList;
    } catch (e) {
      log.e('error getting user configuration: $e');
      throw 'could not get user configurations';
    }
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
