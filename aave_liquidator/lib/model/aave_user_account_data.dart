class AaveUserAccountData {
  String userAddress;
  double totalCollateralEth;
  double totalDebtETH;
  double availableBorrowsETH;
  double currentLiquidationThreshold;
  double ltv;
  double healthFactor;
  Map collateralReserve;
  Map variableDebtReserve;
  Map stableDebtReserve;
  double liquidationCollateralPrice;

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
    this.liquidationCollateralPrice = 0,
  });
  @override
  String toString() {
    return 'user: $userAddress,\n totalCollateralEth: $totalCollateralEth,\n totalDebtETH: $totalDebtETH,\n availableBorrowsETH: $availableBorrowsETH;\n currentLiquidationThreshold: $currentLiquidationThreshold;\n maxLTV: $ltv;\n healthFactor: $healthFactor;\n collateral: $collateralReserve:\n stable debt: $stableDebtReserve;\n variabledebt: $variableDebtReserve;';
  }

  Map<String, dynamic> toJson() => {
        "userAddress": userAddress,
        "totalCollateralEth": totalCollateralEth,
        "totalDebtETH": totalDebtETH,
        "availableBorrowsETH": availableBorrowsETH,
        "currentLiquidationThreshold": currentLiquidationThreshold,
        "ltv": ltv,
        "healthFactor": healthFactor,
        "collateralReserve": collateralReserve,
        "variabelDebtReserve": variableDebtReserve,
        "stableDebtReserve": stableDebtReserve,
      };
}

class AaveUserReserveData {
  Map<String, double> collateral;
  Map<String, double> stableDebt;
  Map<String, double> variableDebt;

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

class AaveReserveData {
  String assetAddress;
  String liquidationThreshold;
  String liquidationBonus;
  String assetPrice;
  String assetPriceETH;

  AaveReserveData(
      {required this.assetAddress,
      required this.liquidationThreshold,
      required this.liquidationBonus,
      required this.assetPrice,
      required this.assetPriceETH});
}
