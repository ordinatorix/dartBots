import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/helper/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/helper/user_parser.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:aave_liquidator/services/mongod_service.dart';

import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveUserManager');

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
    _store = mongod;
    _config = config;
    _aaveContracts = aaveContracts;
  }

  late List<AaveReserveData> _aaveReserveList;

  /// get reservelist from db.

  /// Query specific users
  /// TODO: using [getUserAccountData] update the db with new data from userwith  UltraLow Health Factor (ULHF).
  ///

  /// Get user account data from Aave.
  ///
  /// Requires a list of users
  Future<List<AaveUserAccountData>> getUserAccountData(
      {required List<String> userList}) async {
    log.i('getUserAccountData');
    try {
      if (userList.isEmpty) {
        throw 'no user given';
      }
      _aaveReserveList = await _store.getReservesFromDb();

      log.i(
          'getting user account data of ${userList.length} users.\n Please wait...');
      List<AaveUserAccountData> _aaveUserList = [];

      /// Iterate throught the list of users and get their user account data.
      for (var user in userList) {
        EthereumAddress _userAddress = EthereumAddress.fromHex(user);
        final GetUserAccountData userAccountData = await _aaveContracts
            .lendingPoolContract
            .getUserAccountData(_userAddress);

        /// Only keep users with a health factor below [_config.focusHealthFactor].
        if (userAccountData.healthFactor < _config.focusHealthFactor) {
          AaveUserReserveData _userReserveData =
              await _getAaveUserReserveData(userAddress: _userAddress);
          AaveUserAccountData _userData = _parser.parseUserAccountData(
              userAddress: _userAddress,
              userAccountData: userAccountData,
              userReserveData: _userReserveData);

          _aaveUserList.add(_userData);
        }
      }

      /// Bulk update db.
      await _store.bulkUpdateUsers(_aaveUserList);
      log.v('Found ${_aaveUserList.length} users at risk of liquidation.');
      return _aaveUserList;
    } catch (e) {
      log.e('error getting user account data: $e');
      throw 'Could not get user account data';
    }
  }

  /// Get user reserve data for specific asset.
  Future<AaveUserReserveData> _getAaveUserReserveData({
    required EthereumAddress userAddress,
  }) async {
    log.v('getAaveUserReserveData | user address: $userAddress');
    try {
      List _userConfig = await _getAaveUserConfig(userAddress);
      Map<String, List> _userReserves = _parser.mixAndMatch(
        userConfig: _userConfig,
        aaveReserveList: _aaveReserveList,
      );
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
          (value) => userReserveData.currentATokenBalance.toString(),
          ifAbsent: () => userReserveData.currentATokenBalance.toString(),
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
          (value) => userReserveData.currentVariableDebt.toString(),
          ifAbsent: () => userReserveData.currentVariableDebt.toString(),
        );

        /// Get user stable debt.
        _aaveUserReserveData.stableDebt.update(
          debt,
          (value) => userReserveData.currentStableDebt.toString(),
          ifAbsent: () => userReserveData.currentStableDebt.toString(),
        );
      }

      return _aaveUserReserveData;
    } catch (e) {
      log.e('error getting user reserve data: $e');
      throw 'error getting user reserve data';
    }
  }

  /// Get user configuration across all reserve from aave.
  Future<List> _getAaveUserConfig(EthereumAddress aaveUser) async {
    log.v('_getAaveUserConfig | aaveUser: $aaveUser');
    try {
      /// Get user configuration data from aave.
      final rawUserConfigList = await _aaveContracts.lendingPoolContract
          .getUserConfiguration(aaveUser);

      BigInt userConfig = rawUserConfigList.first;

      List _userReserveList = [];

      /// Convert result to binary string.
      String userConfigBinary = userConfig.toRadixString(2);

      /// Check to see if length is even.
      /// This is needed before splitting into binary pairs.
      /// Pad beginning of string with ["00"] if odd.
      if (userConfigBinary.length % 2 != 0) {
        userConfigBinary =
            userConfigBinary.padLeft(userConfigBinary.length + 1, '0');
      }

      /// Verify that the lenght of the reserves list is the same as the number
      /// of pairs. If not, pad at beginning of string  with ["0"].
      int numberOfPairs = (userConfigBinary.length / 2).round();

      if (numberOfPairs != _aaveReserveList.length) {
        int diff = (_aaveReserveList.length - numberOfPairs).round();

        int padLength = (numberOfPairs + diff) * 2;

        userConfigBinary = userConfigBinary.padLeft(padLength, '0');
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
      log.v(
          'userReserveList: $_userReserveList ; lengthRatio: ${_userReserveList.length}:${_aaveReserveList.length}');

      return _userReserveList;
    } catch (e) {
      log.e('error getting user configuration: $e');
      throw 'could not get user configurations';
    }
  }
}
