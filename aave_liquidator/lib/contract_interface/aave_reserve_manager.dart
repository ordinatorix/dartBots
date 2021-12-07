import 'package:aave_liquidator/abi/aave_abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/contract_interface/chain_link_interface.dart';
// import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/helper/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/logger.dart';

import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/services/mongod_service.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveReserveManager');

class AaveReserveManager {
  // late Config _config;
  late MongodService _store;
  late AaveContracts _aaveContracts;
  AaveReserveManager({
    // required Config config,
    required MongodService mongod,
    required AaveContracts aaveContracts,
  }) {
    _aaveContracts = aaveContracts;
    _store = mongod;
  }

  /// Get Aave reserve list.
  ///
  /// returns [List<EthereumAddress>].
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

  /// Get reserve asset token symbol from aave
  ///
  /// returns [List]
  Future<List> getTokenSymbol() async {
    log.i('getTokenSymbol');
    try {
      return await _aaveContracts.protocolDataProviderContract
          .getAllReservesTokens();
    } catch (e) {
      log.e('error getting token symol: $e');
      throw 'error getting token symol';
    }
  }

  /// Get reserve configuration data.
  ///
  /// This will return [AaveReserveConfigData]
  /// which includes [liquidationThreshold] & [liquidationBonus]

  Future<AaveReserveConfigData> getAaveReserveConfigurationData(
      {required EthereumAddress asset}) async {
    log.v('getAaveReserveConfigurationData');
    try {
      final reserveConfig = await _aaveContracts.protocolDataProviderContract
          .getReserveConfigurationData(asset);
      return _parseReserveConfig(reserveConfig);
    } catch (e) {
      log.e('error getting reserve config data: $e');
      throw 'error getting reserve config data';
    }
  }

  /// Parse Aave reserve config data.
  AaveReserveConfigData _parseReserveConfig(GetReserveConfigurationData data) {
    log.v('_parseReserveConfig');
    return AaveReserveConfigData(
      liquidationBonus: data.liquidationBonus,
      liquidationThreshold: data.liquidationThreshold,
      decimals: data.decimals,
    );
  }

  /// Get all reserve configuration data.
  ///
  /// awaits for all to futures to complete.
  ///
  /// Returns a list of [AaveReserveConfigData]
  Future<List<AaveReserveConfigData>> getAllReserveAssetConfigData(
      List<EthereumAddress> assetAddress) async {
    log.i('getAllReserveAssetConfigData');
    try {
      List<AaveReserveConfigData> _reserveConfigList = await Future.wait([
        for (EthereumAddress asset in assetAddress)
          getAaveReserveConfigurationData(asset: asset),
      ]);

      return _reserveConfigList;
    } catch (e) {
      log.e('error getting all reserve asset config data: $e');
      throw 'error getting all reserve config data';
    }
  }

  /// Gets the asset price from aave.
  ///
  /// Returns the price of the asset in ETH wei units
  Future<BigInt> getReserveAssetPriceFromAave(String asset) async {
    log.i('getReserveAssetPriceFromAave');
    try {
      final BigInt _price = await _aaveContracts.aavePriceProvider
          .getAssetPrice(EthereumAddress.fromHex(asset));

      return _price;
    } catch (e) {
      log.e('error getting asset price from aave: $e');
      throw 'no price from aave';
    }
  }

  /// Gets all assets price from aave.
  /// Returns an array of prices in ETH wei units
  Future<List<BigInt>> getAllReserveAssetPrice(
      List<EthereumAddress> assets) async {
    log.i('getAllReserveAssetPrice');
    try {
      List<BigInt> _priceList = [];

      final List _rawPriceList =
          await _aaveContracts.aavePriceProvider.getAssetsPrices(assets);
      for (BigInt price in _rawPriceList) {
        _priceList.add(price);
      }
      return _priceList;
    } catch (e) {
      log.e('error getting all asset price from aave: $e');
      throw 'error getting all prices from aave';
    }
  }

  pollReserveData({required ChainLinkPriceOracle oracle}) async {
    log.i('_pollReserveData');
    try {
      /// get reserve data from db.
      final List<AaveReserveData> reserveDataList =
          await _store.getReservesFromDb();
      log.v('reserve list in db: $reserveDataList');

      /// get list of assets from aave.
      final List<EthereumAddress> _assetsList = await getAaveReserveList();
      log.v('assets list: $_assetsList');

      /// get aave reserve assets symbol
      final List _assetSymbolList = await getTokenSymbol();
      log.v('symbol list: $_assetSymbolList');

      /// get price from aave
      final List<BigInt> _assetPriceList =
          await getAllReserveAssetPrice(_assetsList);
      log.v('asset price list: $_assetPriceList');

      /// get asset config from aave
      final List<AaveReserveConfigData> _assetConfigList =
          await getAllReserveAssetConfigData(_assetsList);
      log.v('asset config list: $_assetConfigList');

      /// get asset price from chainlink
      final List<BigInt> _oracleAssetPriceList =
          await oracle.getAllAssetsPrice(_assetsList);
      log.v('oracle pricelist: $_oracleAssetPriceList');

      /// update [reserveData] with new data
      for (int i = 0; i < _assetsList.length; i++) {
        int index = reserveDataList.indexWhere(
            (element) => element.assetAddress == _assetsList[i].toString());

        List tokenData = _assetSymbolList
            .firstWhere((element) => element[1] == _assetsList[i]);

        if (index == -1) {
          reserveDataList.add(AaveReserveData(
            assetSymbol: tokenData[0],
            assetAddress: _assetsList[i].toString(),
            assetConfig: _assetConfigList[i],
            aaveAssetPrice: _assetPriceList[i],
            assetPrice: _oracleAssetPriceList[i] == BigInt.from(-1)
                ? _assetPriceList[i]
                : _oracleAssetPriceList[i],
          ));
        } else {
          reserveDataList[index] = AaveReserveData(
            assetSymbol: tokenData[0],
            assetAddress: _assetsList[i].toString(),
            assetConfig: _assetConfigList[i],
            aaveAssetPrice: _assetPriceList[i],
            assetPrice: _oracleAssetPriceList[i] == BigInt.from(-1)
                ? _assetPriceList[i]
                : _oracleAssetPriceList[i],
          );
        }
      }

      /// update db with new reserve data.
      final reset = await _store.resetReserveData(reserveDataList);
      log.v('done updating db with reserve: $reset');
    } catch (e) {
      log.e('error polling: $e');
      throw ' shit fuck up!';
    }
  }

  _updateAaveReserveData() async {
    //TODO: review this
    try {
      final List<EthereumAddress> _reserveList = await getAaveReserveList();
      final List<BigInt> _assetsPrice =
          await getAllReserveAssetPrice(_reserveList);

      for (var asset in _reserveList) {
        final res = await getAaveReserveConfigurationData(asset: asset);

        // parse reserve data
        final AaveReserveData _reserveData = AaveReserveData(
          assetSymbol: '',
          assetAddress: asset.toString(),
          assetConfig: res,
          assetPrice: BigInt.zero,
          aaveAssetPrice: BigInt.zero,
        );
        // add to db
        _store.updateAaveReserve(_reserveData);
      }
    } catch (e) {
      log.e('error updating aave reserve data: $e');
      throw 'error updating reserve data';
    }
  }
}
