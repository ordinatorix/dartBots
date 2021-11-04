class AaveReserveData {
  String assetAddress;
  AaveReserveConfigData assetConfig;
  double assetPrice;
  double assetPriceETH;
  double aaveAssetPrice;

  AaveReserveData({
    required this.assetAddress,
    required this.assetConfig,
    required this.assetPrice,
    required this.assetPriceETH,
    required this.aaveAssetPrice,
  });

  Map<String, dynamic> toJson() => {
        "assetAddress": assetAddress,
        "assetConfiguration": assetConfig.toJson(),
        "assetPrice": assetPrice,
        "assetPriceETH": assetPriceETH,
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
