import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/helper/user_parser.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';

import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveUserLiquidator');

class AaveUserManager {
  late MongodService _store;
  late Config _config;
  final UserParser _parser = UserParser();
  late AaveContracts _aaveContracts;
  AaveUserManager({
    required Config config,
    required AaveContracts aaveContracts,
    required MongodService mongod,
  }) {
    _aaveContracts = aaveContracts;
  }

  late List aaveReserveList; // TODO: fetch from db.

  /// get reservelist from db.

  /// Query specific users
  /// TODO: using [getUserAccountData] update the db with new data from userwith  UltraLow Health Factor (ULHF).
  ///

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
        final GetUserAccountData userAccountData = await _aaveContracts
            .lendingPoolContract
            .getUserAccountData(_userAddress);

        /// Only keep users with a health factor below [_config.focusHealthFactor].
        if (userAccountData.healthFactor.toDouble() <
            _config.focusHealthFactor) {
          log.d('found accounts with low Health factor');

          AaveUserReserveData _userReserveData =
              await getAaveUserReserveData(userAddress: _userAddress);
          AaveUserAccountData _userData = _parser.parseUserAccountData(
              userAddress: _userAddress,
              userAccountData: userAccountData,
              userReserveData: _userReserveData);
          log.d('user data in json: ${_userData.toJson()}');
          // String jsonEncodedUserData = jsonEncode(_userData);
          _aaveUserList.add(_userData.toJson());

          //TODO: upload to each user to db?

          _store.updateUser(_userData.toJson());
        }
      }
      log.i('Found ${_aaveUserList.length} users at risk of liquidation.');
      return _aaveUserList;
    } catch (e) {
      log.e('error getting user account data: $e');
      throw 'Could not get user account data';
    }
  }

  /// Get user reserve data for specific asset.
  Future<AaveUserReserveData> getAaveUserReserveData({
    required EthereumAddress userAddress,
  }) async {
    log.d('getAaveUserReserveData | user address: $userAddress');
    try {
      List _userConfig = await _getAaveUserConfig(userAddress);
      Map<String, List> _userReserves = _parser.mixAndMatch(_userConfig);
      AaveUserReserveData _aaveUserReserveData = AaveUserReserveData(
        collateral: {},
        stableDebt: {},
        variableDebt: {},
      );

      for (final collateral in _userReserves['collateral']!) {
        GetUserReserveData userReserveData = await _aaveContracts
            .protocolDataProviderContract
            .getUserReserveData(
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
        GetUserReserveData userReserveData = await _aaveContracts
            .protocolDataProviderContract
            .getUserReserveData(
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

  /// Get user configuration across all reserve from aave.
  Future<List> _getAaveUserConfig(EthereumAddress aaveUser) async {
    log.v('getting user config | aaveUser: $aaveUser');
    try {
      final rawUserConfigList = await _aaveContracts.lendingPoolContract
          .getUserConfiguration(aaveUser);

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
}
