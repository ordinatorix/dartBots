class AaveUserAccountData {
  String userAddress;
  double totalCollateralEth;
  double totalDebtETH;
  double availableBorrowsETH;
  double currentLiquidationThreshold;
  double ltv;
  double healthFactor;
  List<String> collateralReserve;
  List<String> debtReserve;
  AaveUserAccountData({
    required this.userAddress,
    required this.totalCollateralEth,
    required this.totalDebtETH,
    required this.availableBorrowsETH,
    required this.currentLiquidationThreshold,
    required this.ltv,
    required this.healthFactor,
    required this.collateralReserve,
    required this.debtReserve,
  });
  @override
  String toString() {
    return 'user: $userAddress,\n totalCollateralEth: $totalCollateralEth,\n totalDebtETH: $totalDebtETH,\n availableBorrowsETH: $availableBorrowsETH;\n currentLiquidationThreshold: $currentLiquidationThreshold;\n maxLTV: $ltv;\n healthFactor: $healthFactor,\n collateralReserve: $collateralReserve,\n debtReserve: $debtReserve';
  }

  Map<String, dynamic> toJson() => {
        "userAddress": userAddress,
        "totalCollateralEth": totalCollateralEth.toString(),
        "totalDebtETH": totalDebtETH.toString(),
        "availableBorrowsETH": availableBorrowsETH.toString(),
        "currentLiquidationThreshold": currentLiquidationThreshold.toString(),
        "ltv": ltv.toString(),
        "healthFactor": healthFactor.toString(),
        "collateralReserve": collateralReserve.toString(),
        "debtReserve": debtReserve.toString(),
      };
}
