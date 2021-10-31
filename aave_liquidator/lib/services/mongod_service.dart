import 'dart:async';

import 'package:aave_liquidator/config.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:mongo_dart/mongo_dart.dart';

final log = getLogger('MongodService');

class MongodService {
  MongodService(Config config) {
    _config = config;
    _connectDb();
  }
  late Config _config;
  late Db db;
  late DbCollection userStore;
  final Completer<bool> isConnected = Completer<bool>();
  Future<bool> get isReady => isConnected.future;

  /// Connect to db.
  _connectDb() async {
    //TODO: use secure connection.
    log.i('_connectDb');
    try {
      db = Db(_config.dbUri);

      await db.open();

      isConnected.complete(db.isConnected);
    } catch (e) {
      log.e('error connecting to db: $e');
    }
  }

  /// Close connection to DB.
  closeDb() async {
    log.i('closeDb');
    try {
      await db.close();
    } catch (e) {
      log.e('error closing db connection: $e');
    }
  }

  /// insert newdocument to db collection.
  saveUser(Map<String, dynamic> userAccount) {
    log.i('saveUser | userAccount: $userAccount');
    userStore = db.collection(_config.aaveUserCollection);
    userStore.insertOne(userAccount);
  }

  /// save all users at once.
  /// WARNING: This will drop the exixtig collection and replace it.
  resetUsers(List<Map<String, dynamic>> userList) async {
    log.i('resetUsers | userList: $userList');
    try {
      await db.dropCollection(_config.aaveUserCollection);

      userStore = db.collection(_config.aaveUserCollection);

      await userStore.insertMany(userList);
    } catch (e) {
      log.e('error adding user to db :$e');
    }
  }

  /// Replace existing document with new one.
  /// Add document if does not exist.
  replaceUserData(Map<String, dynamic> userData) async {
    log.i('replaceUserData | userData: $userData');
    try {
      userStore = db.collection(_config.aaveUserCollection);
      userStore.replaceOne(
          where.eq('userAddress', userData['userAddress']), userData,
          upsert: true);
    } catch (e) {
      log.e('error replacing user data: $e');
    }
  }
}
