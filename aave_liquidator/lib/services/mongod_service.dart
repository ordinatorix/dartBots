import 'dart:async';

import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_reserve_model.dart';
import 'package:aave_liquidator/model/aave_user_account_data.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:aave_liquidator/token_address.dart' as token;

final log = getLogger('MongodService');

class MongodService {
  MongodService(Config config) {
    _config = config;
    _connectDb();
    _setupCollections();
  }
  late Config _config;
  late Db _db;
  late DbCollection _userStore;
  final Completer<bool> isConnected = Completer<bool>();

  late DbCollection _reserveStore;
  Future<bool> get isReady => isConnected.future;

  /// Connect to _db.
  _connectDb() async {
    //TODO: use secure connection.
    log.i('_connectDb');
    try {
      _db = Db(_config.dbUri);

      await _db.open();

      isConnected.complete(_db.isConnected);
    } catch (e) {
      log.e('error connecting to _db: $e');
    }
  }

  /// Close connection to DB.
  closeDb() async {
    log.i('closeDb');
    try {
      await _db.close();
    } catch (e) {
      log.e('error closing _db connection: $e');
    }
  }

  /// setup collections
  _setupCollections() async {
    log.i('_setupCollections');
    await isReady;
    _reserveStore = _db.collection(_config.aaveReserveCollectionName);
    _userStore = _db.collection(_config.aaveUserCollection);
  }

  /// Insert new users to collection.
  saveUser(Map<String, dynamic> userAccount) {
    log.i('saveUser | userAccount: $userAccount');

    _userStore.insertOne(userAccount);
  }

  /// Reset all users at once.
  ///
  /// !!![WARNING]!!!
  ///
  /// This will drop the exixting collection and replace it.
  /// use with caution!!!
  resetUsers(List<Map<String, dynamic>> userList) async {
    log.i('resetUsers | userList: $userList');
    try {
      await _db.dropCollection(_config.aaveUserCollection);

      await _userStore.insertMany(userList);
    } catch (e) {
      log.e('error adding user to _db :$e');
    }
  }

  /// Update existing user document with new one.
  /// Adds document if does not exist.
  updateUser(AaveUserAccountData userData) async {
    log.i('replaceUserData | userData: $userData');
    try {
      final _jsonUserData = userData.toJson();
      await _userStore.replaceOne(
        where.eq('userAddress', _jsonUserData['userAddress']),
        _jsonUserData,
        upsert: true,
      );
    } catch (e) {
      log.e('error replacing user data: $e');
    }
  }

  bulkUpdateUsers(List<AaveUserAccountData> userDataList) async {
    log.i('bulkUpdateUsers');
    try {
      /// Setup bulk operation
      var bulk = OrderedBulk(_userStore);

      for (AaveUserAccountData userData in userDataList) {
        ///Convert to json
        final _jsonUserData = userData.toJson();

        Map<String, dynamic>? data = await _userStore
            .findOne(where.eq('userAddress', _jsonUserData['userAddress']));

        if (data != null) {
          bulk.replaceOne(ReplaceOneStatement(
            {
              "userAddress": data['userAddress'],
              "totalCollateralEth": data['totalCollateralEth'],
              "totalDebtETH": data['totalDebtETH'],
              "availableBorrowsETH": data['availableBorrowsETH'],
              "currentLiquidationThreshold":
                  data['currentLiquidationThreshold'],
              "ltv": data['ltv'],
              "healthFactor": data['healthFactor'],
              "collateralReserve": data['collateralReserve'],
              "variableDebtReserve": data['variableDebtReserve'],
              "stableDebtReserve": data['stableDebtReserve'],
            },
            _jsonUserData,
            upsert: true,
          ));
        } else {
          bulk.insertOne(_jsonUserData);
        }
      }
      var ret = await bulk.executeBulk();
      log.d('bulk returned: $ret');
    } catch (e) {
      log.e('error bulk updating users: $e');
    }
  }

  /// Get users with [tokenAddress] as collateral asset.
  Future<List<AaveUserAccountData>> getCollateralUsers(
      String tokenAddress) async {
    log.i('getCollateralUsers | token address: $tokenAddress');

    List<AaveUserAccountData> users = await _userStore
        .find(where.gt('collateralReserve.$tokenAddress', '0'))
        .map((event) => _parseUserAccountData(event))
        .toList();

    log.d('collateral users: $users');

    return users;
  }

  /// Get users with [tokenAddress] as debt asset.
  Future<List<AaveUserAccountData>> getDebtUsers(String tokenAddress) async {
    log.i('getDetUsers | token address: $tokenAddress');

    List<AaveUserAccountData> users = await _userStore
        .find({
          r"$and": [
            {
              r"$or": [
                {
                  "variableDebtReserve.$tokenAddress": {r"$gt": '0'}
                },
                {
                  "stableDebtReserve.$tokenAddress": {r"$gt": '0'}
                }
              ]
            }
          ]
        })
        .map((event) => _parseUserAccountData(event))
        .toList();
    log.d('debt users: $users');

    return users;
  }

  AaveUserAccountData _parseUserAccountData(event) {
    return AaveUserAccountData(
        userAddress: event['userAddress'],
        totalCollateralEth: BigInt.parse(event['totalCollateralEth']),
        totalDebtETH: BigInt.parse(event['totalDebtETH']),
        availableBorrowsETH: BigInt.parse(event['availableBorrowsETH']),
        currentLiquidationThreshold:
            BigInt.parse(event['currentLiquidationThreshold']),
        ltv: BigInt.parse(event['ltv']),
        healthFactor: BigInt.parse(event['healthFactor']),
        collateralReserve: event['collateralReserve'],
        variableDebtReserve: event['variableDebtReserve'],
        stableDebtReserve: event['stableDebtReserve']);
  }

  //
  //
  //-------------------RESERVES----------------------///
  //
  //

  /// Get reserve count.
  Future<int> getReserveCount() async {
    log.i('getReserveCount');
    final count = await _reserveStore.count();
    log.v('count: $count');
    return count;
  }

  /// get reserves from _db
  ///
  Future<List<AaveReserveData>> getReservesFromDb() async {
    log.i('getReservesFromDb');
    try {
      var res = await _reserveStore.find().toList();
      return res.map((e) => _parseReserveToAaveReserveData(e)).toList();
    } catch (e) {
      log.e('error getting reserves from db: $e');
      throw 'could not find reserves';
    }
  }

  /// parse reservedata.
  AaveReserveData _parseReserveToAaveReserveData(data) {
    log.v('_parseReserveToAaveReserveData');

    return AaveReserveData(
      assetSymbol: data['assetSymbol'],
      assetAddress: data['assetAddress'],
      assetConfig: AaveReserveConfigData(
        liquidationThreshold:
            BigInt.parse(data['assetConfiguration']['liquidationThreshold']),
        liquidationBonus:
            BigInt.parse(data['assetConfiguration']['liquidationBonus']),
        decimals: BigInt.parse(data['assetConfiguration']['decimals']),
      ),
      assetPrice: BigInt.parse(data['assetPrice']),
      aaveAssetPrice: BigInt.parse(data['aaveAssetPrice']),
    );
  }

  Future<bool> resetReserveData(List<AaveReserveData> reserveDataList) async {
    log.i(
        'resetReserveData | reserveDataList length: ${reserveDataList.length}');
    try {
      await _reserveStore.drop();
      List<Map<String, dynamic>> documents =
          reserveDataList.map((e) => e.toJson()).toList();

      var res = await _reserveStore.insertMany(documents);
      return res.success;
    } catch (e) {
      log.e('error resetting reserve data in db: $e');
      throw 'db update failed';
    }
  }

  /// Updates the asset price with price from chainlink
  updateReserveAssetPrice({
    required String assetAddress,
    required BigInt newAssetPrice,
  }) async {
    try {
      final reserveStore = _db.collection(_config.aaveReserveCollectionName);
      await reserveStore.updateOne(
        where.eq('reserveAddress', assetAddress),
        modify.set('assetPrice', newAssetPrice),
      );
    } catch (e) {
      log.e('error updating asset price: $e');
    }
  }

  /// Updates all data of a given asset reserve.
  updateAaveReserve(AaveReserveData reserveData) async {
    try {
      final reserveStore = _db.collection(_config.aaveReserveCollectionName);
      await reserveStore.replaceOne(
        where.eq('reserveAddress', reserveData.assetAddress),
        reserveData.toJson(),
        upsert: true,
      );
    } catch (e) {
      log.e('error updating reserve: $e');
    }
  }
}
