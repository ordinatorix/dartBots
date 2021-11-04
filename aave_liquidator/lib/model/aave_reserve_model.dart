class AaveReserveData {
  String assetSymbol;
  String assetAddress;
  AaveReserveConfigData assetConfig;
  double assetPrice;
  double aaveAssetPrice;

  AaveReserveData({
    required this.assetSymbol,
    required this.assetAddress,
    required this.assetConfig,
    required this.assetPrice,
    required this.aaveAssetPrice,
  });

  Map<String, dynamic> toJson() => {
        "assetSymbol": assetSymbol,
        "assetAddress": assetAddress,
        "assetConfiguration": assetConfig.toJson(),
        "assetPrice": assetPrice,
        "aaveAssetPrice": aaveAssetPrice,
      };
}

class AaveReserveConfigData {
  double liquidationThreshold;
  double liquidationBonus;
  AaveReserveConfigData({
    required this.liquidationBonus,
    required this.liquidationThreshold,
  });
  Map<String, dynamic> toJson() => {
        "liquidationBonus": liquidationBonus,
        "liquidationThreshold": liquidationThreshold,
      };
}
