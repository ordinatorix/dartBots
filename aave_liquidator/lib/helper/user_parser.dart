import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('UserParser');

class UserParser {
  /// parse user data
  AaveUserAccountData parseUserAccountData({
    required EthereumAddress userAddress,
    required GetUserAccountData userAccountData,
    required AaveUserReserveData userReserveData,
  }) {
    log.v('parsing user data');

    final parsedUserAccountData = AaveUserAccountData(
      userAddress: userAddress.toString(),
      totalCollateralEth: userAccountData.totalCollateralETH,
      collateralReserve: userReserveData.collateral,
      totalDebtETH: userAccountData.totalDebtETH,
      stableDebtReserve: userReserveData.stableDebt,
      variableDebtReserve: userReserveData.variableDebt,
      availableBorrowsETH: userAccountData.availableBorrowsETH,
      currentLiquidationThreshold: userAccountData.currentLiquidationThreshold,
      ltv: userAccountData.ltv,
      healthFactor: userAccountData.healthFactor,
    );

    return parsedUserAccountData;
  }

  /// format user data to write to file
  Map<String, List> mixAndMatch({
    required List userConfig,
    required List<AaveReserveData> aaveReserveList,
  }) {
    log.v('Format user data');

    /// for each reserve pair in the list,
    /// if the reserve pair is "10"
    List<String> collateralReserve = [];
    List<String> debtReserve = [];
    for (var i = 0; i < aaveReserveList.length; i++) {
      if (userConfig[i] == '10') {
        log.v('adding ${aaveReserveList[i].assetAddress} to collateral');

        /// add reserve address to colateral list
        collateralReserve.add(aaveReserveList[i].assetAddress);
      } else if (userConfig[i] == '01') {
        log.v('adding ${aaveReserveList[1].assetAddress} to debt');

        /// add reserve address to debt list
        debtReserve.add(aaveReserveList[i].assetAddress);
      } else if (userConfig[i] == '11') {
        log.v(
            'adding ${aaveReserveList[1].assetAddress} to collateral and debt');

        /// add reserve address to collaterral and debt list.
        collateralReserve.add(aaveReserveList[i].assetAddress);
        debtReserve.add(aaveReserveList[i].assetAddress);
      }
    }
    return {'collateral': collateralReserve, 'debt': debtReserve};
  }
}
