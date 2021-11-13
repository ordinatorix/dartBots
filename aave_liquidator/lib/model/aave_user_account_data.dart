class AaveUserAccountData {
  String userAddress;
  BigInt totalCollateralEth;
  BigInt totalDebtETH;
  BigInt availableBorrowsETH;
  BigInt currentLiquidationThreshold;
  BigInt ltv;
  BigInt healthFactor;
  Map collateralReserve;
  Map variableDebtReserve;
  Map stableDebtReserve;
  // BigInt liquidationCollateralPrice;

  AaveUserAccountData({
    required this.userAddress,
    required this.totalCollateralEth,
    required this.totalDebtETH,
    required this.availableBorrowsETH,
    required this.currentLiquidationThreshold,
    required this.ltv,
    required this.healthFactor,
    required this.collateralReserve,
    required this.variableDebtReserve,
    required this.stableDebtReserve,
    // this.liquidationCollateralPrice = 0,
  });
  @override
  String toString() {
    return 'user: $userAddress,\n totalCollateralEth: $totalCollateralEth,\n totalDebtETH: $totalDebtETH,\n availableBorrowsETH: $availableBorrowsETH;\n currentLiquidationThreshold: $currentLiquidationThreshold;\n maxLTV: $ltv;\n healthFactor: $healthFactor;\n collateral: $collateralReserve:\n stable debt: $stableDebtReserve;\n variabledebt: $variableDebtReserve;';
  }

  Map<String, dynamic> toJson() => {
        "userAddress": userAddress,
        "totalCollateralEth": totalCollateralEth.toString(),
        "totalDebtETH": totalDebtETH.toString(),
        "availableBorrowsETH": availableBorrowsETH.toString(),
        "currentLiquidationThreshold": currentLiquidationThreshold.toString(),
        "ltv": ltv.toString(),
        "healthFactor": healthFactor.toString(),
        "collateralReserve": collateralReserve,
        "variableDebtReserve": variableDebtReserve,
        "stableDebtReserve": stableDebtReserve,
      };
}

class AaveUserReserveData {
  Map<String, String> collateral;
  Map<String, String> stableDebt;
  Map<String, String> variableDebt;

  AaveUserReserveData({
    this.collateral = const {},
    this.stableDebt = const {},
    this.variableDebt = const {},
  });
  @override
  String toString() {
    return 'collateral: $collateral;\n stable debt: $stableDebt;\n variable debt: $variableDebt';
  }

  
}
