import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('UserParser');

class UserParser {
  late List aaveReserveList; // TODO: fetch from db.
  /// parse user data
  AaveUserAccountData parseUserAccountData({
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
  Map<String, List> mixAndMatch(List pairList) {
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
