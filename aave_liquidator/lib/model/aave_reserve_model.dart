class AaveReserveData {
  String assetSymbol;
  String assetAddress;
  AaveReserveConfigData assetConfig;
  BigInt assetPrice;
  BigInt aaveAssetPrice;

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
        "assetPrice": assetPrice.toString(),
        "aaveAssetPrice": aaveAssetPrice.toString(),
      };

  @override
  String toString() {
    return 'symbol: $assetSymbol, address: $assetAddress, price: $aaveAssetPrice';
  }
}

class AaveReserveConfigData {
  BigInt liquidationThreshold;
  BigInt liquidationBonus;
  BigInt decimals;
  AaveReserveConfigData({
    required this.liquidationBonus,
    required this.liquidationThreshold,
    required this.decimals,
  });
  Map<String, dynamic> toJson() => {
        "liquidationBonus": liquidationBonus.toString(),
        "liquidationThreshold": liquidationThreshold.toString(),
        "decimals": decimals.toString(),
      };

  @override
  String toString() {
    return 'liquidation bonus: $liquidationBonus, liquidation threshold: $liquidationThreshold';
  }
}
