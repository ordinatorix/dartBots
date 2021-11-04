import 'package:aave_liquidator/abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';

import 'package:aave_liquidator/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveReserveManager');

class AaveReserveManager {
  late Config _config;
  late MongodService _store;
  late AaveContracts _aaveContracts;
  AaveReserveManager({
    required Config config,
    required MongodService mongod,
    required AaveContracts aaveContracts,
  }) {
    _aaveContracts = aaveContracts;
    _store = mongod;
  }

  /// Get Aave reserve list.
  ///
  Future<List<EthereumAddress>> getAaveReserveList() async {
    log.i('getAaveReserveList');

    try {
      List<EthereumAddress> _reserveList =
          await _aaveContracts.lendingPoolContract.getReservesList();

      return _reserveList;
    } catch (e) {
      log.e('error getting aave reserve list: $e');
      throw 'Could not get aave reserve list.';
    }
  }

  /// Get reserve configuration data.
  ///
  /// This will return [AaveReserveConfigData]
  /// which includes [liquidationThreshold] & [liquidationBonus]

  Future<AaveReserveConfigData> getAaveReserveConfigurationData(
      {required EthereumAddress asset}) async {
    log.i('getAaveReserveConfigurationData');
    final reserveConfig = await _aaveContracts.protocolDataProviderContract
        .getReserveConfigurationData(asset);
    return _parseReserveConfig(reserveConfig);
  }

  /// Parse Aave reserve config data.
  AaveReserveConfigData _parseReserveConfig(GetReserveConfigurationData data) {
    log.i('_parseReserveConfig');
    return AaveReserveConfigData(
        liquidationBonus: data.liquidationBonus.toDouble(),
        liquidationThreshold: data.liquidationThreshold.toDouble());
  }

  Future<List<AaveReserveConfigData>> getAllReserveAssetConfigData(
      List<EthereumAddress> assetAddress) async {
    log.i('getAllReserveAssetConfigData');
    List<AaveReserveConfigData> _reserveConfigList = await Future.wait([
      for (EthereumAddress asset in assetAddress)
        getAaveReserveConfigurationData(asset: asset),
    ]);
    log.d('config list: $_reserveConfigList');
    return _reserveConfigList;
  }

  /// Gets the asset price from aave.
  ///
  /// Returns the price of the asset in ETH wei units
  Future<double> getReserveAssetPriceFromAave(String asset) async {
    log.i('getReserveAssetPriceFromAave');
    final BigInt _price = await _aaveContracts.aavePriceProvider
        .getAssetPrice(EthereumAddress.fromHex(asset));

    return _price.toDouble();
  }

  /// Gets all assets price from aave.
  /// Returns an array of prices in ETH wei units
  Future<List<double>> getAllReserveAssetPrice(
      List<EthereumAddress> assets) async {
    log.i('getAllReserveAssetPrice');

    List<double> _priceList = [];

    final List _rawPriceList =
        await _aaveContracts.aavePriceProvider.getAssetsPrices(assets);
    for (BigInt price in _rawPriceList) {
      _priceList.add(price.toDouble());
    }
    return _priceList;
  }

  updateAaveReserveData() async {
    final List<EthereumAddress> _reserveList = await getAaveReserveList();
    final List<double> _assetsPrice =
        await getAllReserveAssetPrice(_reserveList);

    for (var asset in _reserveList) {
      final res = await getAaveReserveConfigurationData(asset: asset);

      // parse reserve data
      final AaveReserveData _reserveData = AaveReserveData(
        assetAddress: asset.toString(),
        assetConfig: res,
        assetPrice: 0,
        assetPriceETH: 0,
        aaveAssetPrice: 0,
      );
      // add to db
      _store.updateAaveReserve(_reserveData);
    }
  }
}
