// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":false,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"onBehalfOf","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"borrowRateMode","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"borrowRate","type":"uint256"},{"indexed":true,"internalType":"uint16","name":"referral","type":"uint16"}],"name":"Borrow","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":false,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"onBehalfOf","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":true,"internalType":"uint16","name":"referral","type":"uint16"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"target","type":"address"},{"indexed":true,"internalType":"address","name":"initiator","type":"address"},{"indexed":true,"internalType":"address","name":"asset","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"premium","type":"uint256"},{"indexed":false,"internalType":"uint16","name":"referralCode","type":"uint16"}],"name":"FlashLoan","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"collateralAsset","type":"address"},{"indexed":true,"internalType":"address","name":"debtAsset","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"debtToCover","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"liquidatedCollateralAmount","type":"uint256"},{"indexed":false,"internalType":"address","name":"liquidator","type":"address"},{"indexed":false,"internalType":"bool","name":"receiveAToken","type":"bool"}],"name":"LiquidationCall","type":"event"},{"anonymous":false,"inputs":[],"name":"Paused","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"}],"name":"RebalanceStableBorrowRate","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"repayer","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Repay","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":false,"internalType":"uint256","name":"liquidityRate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"stableBorrowRate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"variableBorrowRate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"liquidityIndex","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"variableBorrowIndex","type":"uint256"}],"name":"ReserveDataUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"}],"name":"ReserveUsedAsCollateralDisabled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"}],"name":"ReserveUsedAsCollateralEnabled","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"rateMode","type":"uint256"}],"name":"Swap","type":"event"},{"anonymous":false,"inputs":[],"name":"Unpaused","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Withdraw","type":"event"},{"inputs":[],"name":"FLASHLOAN_PREMIUM_TOTAL","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"LENDINGPOOL_REVISION","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_NUMBER_RESERVES","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_STABLE_RATE_BORROW_SIZE_PERCENT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"interestRateMode","type":"uint256"},{"internalType":"uint16","name":"referralCode","type":"uint16"},{"internalType":"address","name":"onBehalfOf","type":"address"}],"name":"borrow","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"onBehalfOf","type":"address"},{"internalType":"uint16","name":"referralCode","type":"uint16"}],"name":"deposit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"balanceFromBefore","type":"uint256"},{"internalType":"uint256","name":"balanceToBefore","type":"uint256"}],"name":"finalizeTransfer","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"receiverAddress","type":"address"},{"internalType":"address[]","name":"assets","type":"address[]"},{"internalType":"uint256[]","name":"amounts","type":"uint256[]"},{"internalType":"uint256[]","name":"modes","type":"uint256[]"},{"internalType":"address","name":"onBehalfOf","type":"address"},{"internalType":"bytes","name":"params","type":"bytes"},{"internalType":"uint16","name":"referralCode","type":"uint16"}],"name":"flashLoan","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAddressesProvider","outputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getConfiguration","outputs":[{"components":[{"internalType":"uint256","name":"data","type":"uint256"}],"internalType":"struct DataTypes.ReserveConfigurationMap","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveData","outputs":[{"components":[{"components":[{"internalType":"uint256","name":"data","type":"uint256"}],"internalType":"struct DataTypes.ReserveConfigurationMap","name":"configuration","type":"tuple"},{"internalType":"uint128","name":"liquidityIndex","type":"uint128"},{"internalType":"uint128","name":"variableBorrowIndex","type":"uint128"},{"internalType":"uint128","name":"currentLiquidityRate","type":"uint128"},{"internalType":"uint128","name":"currentVariableBorrowRate","type":"uint128"},{"internalType":"uint128","name":"currentStableBorrowRate","type":"uint128"},{"internalType":"uint40","name":"lastUpdateTimestamp","type":"uint40"},{"internalType":"address","name":"aTokenAddress","type":"address"},{"internalType":"address","name":"stableDebtTokenAddress","type":"address"},{"internalType":"address","name":"variableDebtTokenAddress","type":"address"},{"internalType":"address","name":"interestRateStrategyAddress","type":"address"},{"internalType":"uint8","name":"id","type":"uint8"}],"internalType":"struct DataTypes.ReserveData","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveNormalizedIncome","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveNormalizedVariableDebt","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getReservesList","outputs":[{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getUserAccountData","outputs":[{"internalType":"uint256","name":"totalCollateralETH","type":"uint256"},{"internalType":"uint256","name":"totalDebtETH","type":"uint256"},{"internalType":"uint256","name":"availableBorrowsETH","type":"uint256"},{"internalType":"uint256","name":"currentLiquidationThreshold","type":"uint256"},{"internalType":"uint256","name":"ltv","type":"uint256"},{"internalType":"uint256","name":"healthFactor","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"getUserConfiguration","outputs":[{"components":[{"internalType":"uint256","name":"data","type":"uint256"}],"internalType":"struct DataTypes.UserConfigurationMap","name":"","type":"tuple"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"address","name":"aTokenAddress","type":"address"},{"internalType":"address","name":"stableDebtAddress","type":"address"},{"internalType":"address","name":"variableDebtAddress","type":"address"},{"internalType":"address","name":"interestRateStrategyAddress","type":"address"}],"name":"initReserve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"provider","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"collateralAsset","type":"address"},{"internalType":"address","name":"debtAsset","type":"address"},{"internalType":"address","name":"user","type":"address"},{"internalType":"uint256","name":"debtToCover","type":"uint256"},{"internalType":"bool","name":"receiveAToken","type":"bool"}],"name":"liquidationCall","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"paused","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"address","name":"user","type":"address"}],"name":"rebalanceStableBorrowRate","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"rateMode","type":"uint256"},{"internalType":"address","name":"onBehalfOf","type":"address"}],"name":"repay","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"configuration","type":"uint256"}],"name":"setConfiguration","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bool","name":"val","type":"bool"}],"name":"setPause","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"address","name":"rateStrategyAddress","type":"address"}],"name":"setReserveInterestRateStrategyAddress","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"bool","name":"useAsCollateral","type":"bool"}],"name":"setUserUseReserveAsCollateral","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"rateMode","type":"uint256"}],"name":"swapBorrowRateMode","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"address","name":"to","type":"address"}],"name":"withdraw","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"}]',
    'Aave_lending_pool');

class Aave_lending_pool extends _i1.GeneratedContract {
  Aave_lending_pool(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> FLASHLOAN_PREMIUM_TOTAL({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, '074b2e43'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> LENDINGPOOL_REVISION({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '8afaff02'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> MAX_NUMBER_RESERVES({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'f8119d51'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> MAX_STABLE_RATE_BORROW_SIZE_PERCENT(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'e82fec2f'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> borrow(
      _i1.EthereumAddress asset,
      BigInt amount,
      BigInt interestRateMode,
      BigInt referralCode,
      _i1.EthereumAddress onBehalfOf,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, 'a415bcad'));
    final params = [asset, amount, interestRateMode, referralCode, onBehalfOf];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> deposit(_i1.EthereumAddress asset, BigInt amount,
      _i1.EthereumAddress onBehalfOf, BigInt referralCode,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, 'e8eda9df'));
    final params = [asset, amount, onBehalfOf, referralCode];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> finalizeTransfer(
      _i1.EthereumAddress asset,
      _i1.EthereumAddress from,
      _i1.EthereumAddress to,
      BigInt amount,
      BigInt balanceFromBefore,
      BigInt balanceToBefore,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'd5ed3933'));
    final params = [
      asset,
      from,
      to,
      amount,
      balanceFromBefore,
      balanceToBefore
    ];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> flashLoan(
      _i1.EthereumAddress receiverAddress,
      List<_i1.EthereumAddress> assets,
      List<BigInt> amounts,
      List<BigInt> modes,
      _i1.EthereumAddress onBehalfOf,
      _i2.Uint8List params,
      BigInt referralCode,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, 'ab9c4b5d'));
    final _params = [
      receiverAddress,
      assets,
      amounts,
      modes,
      onBehalfOf,
      params,
      referralCode
    ];
    return write(credentials, transaction, function, _params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> getAddressesProvider(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, 'fe65acfe'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<dynamic> getConfiguration(_i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, 'c44b11f7'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return (response[0] as dynamic);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<dynamic> getReserveData(_i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, '35ea6a75'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return (response[0] as dynamic);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getReserveNormalizedIncome(_i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'd15e0053'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getReserveNormalizedVariableDebt(_i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '386497fd'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<_i1.EthereumAddress>> getReservesList(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, 'd1946dbc'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as List<dynamic>).cast<_i1.EthereumAddress>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetUserAccountData> getUserAccountData(_i1.EthereumAddress user,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'bf92857c'));
    final params = [user];
    final response = await read(function, params, atBlock);
    return GetUserAccountData(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<dynamic> getUserConfiguration(_i1.EthereumAddress user,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, '4417a583'));
    final params = [user];
    final response = await read(function, params, atBlock);
    return (response[0] as dynamic);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initReserve(
      _i1.EthereumAddress asset,
      _i1.EthereumAddress aTokenAddress,
      _i1.EthereumAddress stableDebtAddress,
      _i1.EthereumAddress variableDebtAddress,
      _i1.EthereumAddress interestRateStrategyAddress,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, '7a708e92'));
    final params = [
      asset,
      aTokenAddress,
      stableDebtAddress,
      variableDebtAddress,
      interestRateStrategyAddress
    ];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(_i1.EthereumAddress provider,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[17];
    assert(checkSignature(function, 'c4d66de8'));
    final params = [provider];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> liquidationCall(
      _i1.EthereumAddress collateralAsset,
      _i1.EthereumAddress debtAsset,
      _i1.EthereumAddress user,
      BigInt debtToCover,
      bool receiveAToken,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[18];
    assert(checkSignature(function, '00a718a9'));
    final params = [
      collateralAsset,
      debtAsset,
      user,
      debtToCover,
      receiveAToken
    ];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<bool> paused({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[19];
    assert(checkSignature(function, '5c975abb'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as bool);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> rebalanceStableBorrowRate(
      _i1.EthereumAddress asset, _i1.EthereumAddress user,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[20];
    assert(checkSignature(function, 'cd112382'));
    final params = [asset, user];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> repay(_i1.EthereumAddress asset, BigInt amount,
      BigInt rateMode, _i1.EthereumAddress onBehalfOf,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[21];
    assert(checkSignature(function, '573ade81'));
    final params = [asset, amount, rateMode, onBehalfOf];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setConfiguration(
      _i1.EthereumAddress asset, BigInt configuration,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[22];
    assert(checkSignature(function, 'b8d29276'));
    final params = [asset, configuration];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setPause(bool val,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[23];
    assert(checkSignature(function, 'bedb86fb'));
    final params = [val];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setReserveInterestRateStrategyAddress(
      _i1.EthereumAddress asset, _i1.EthereumAddress rateStrategyAddress,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[24];
    assert(checkSignature(function, '1d2118f9'));
    final params = [asset, rateStrategyAddress];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setUserUseReserveAsCollateral(
      _i1.EthereumAddress asset, bool useAsCollateral,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[25];
    assert(checkSignature(function, '5a3b74b9'));
    final params = [asset, useAsCollateral];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> swapBorrowRateMode(_i1.EthereumAddress asset, BigInt rateMode,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[26];
    assert(checkSignature(function, '94ba89a2'));
    final params = [asset, rateMode];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdraw(
      _i1.EthereumAddress asset, BigInt amount, _i1.EthereumAddress to,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[27];
    assert(checkSignature(function, '69328dec'));
    final params = [asset, amount, to];
    return write(credentials, transaction, function, params);
  }

  /// Returns a live stream of all Borrow events emitted by this contract.
  Stream<Borrow> borrowEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Borrow');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Borrow(decoded);
    });
  }

  /// Returns a live stream of all Deposit events emitted by this contract.
  Stream<Deposit> depositEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Deposit');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Deposit(decoded);
    });
  }

  /// Returns a live stream of all FlashLoan events emitted by this contract.
  Stream<FlashLoan> flashLoanEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('FlashLoan');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return FlashLoan(decoded);
    });
  }

  /// Returns a live stream of all LiquidationCall events emitted by this contract.
  Stream<LiquidationCall> liquidationCallEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('LiquidationCall');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return LiquidationCall(decoded);
    });
  }

  /// Returns a live stream of all Paused events emitted by this contract.
  Stream<Paused> pausedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Paused');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Paused(decoded);
    });
  }

  /// Returns a live stream of all RebalanceStableBorrowRate events emitted by this contract.
  Stream<RebalanceStableBorrowRate> rebalanceStableBorrowRateEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('RebalanceStableBorrowRate');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return RebalanceStableBorrowRate(decoded);
    });
  }

  /// Returns a live stream of all Repay events emitted by this contract.
  Stream<Repay> repayEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Repay');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Repay(decoded);
    });
  }

  /// Returns a live stream of all ReserveDataUpdated events emitted by this contract.
  Stream<ReserveDataUpdated> reserveDataUpdatedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ReserveDataUpdated');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ReserveDataUpdated(decoded);
    });
  }

  /// Returns a live stream of all ReserveUsedAsCollateralDisabled events emitted by this contract.
  Stream<ReserveUsedAsCollateralDisabled> reserveUsedAsCollateralDisabledEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ReserveUsedAsCollateralDisabled');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ReserveUsedAsCollateralDisabled(decoded);
    });
  }

  /// Returns a live stream of all ReserveUsedAsCollateralEnabled events emitted by this contract.
  Stream<ReserveUsedAsCollateralEnabled> reserveUsedAsCollateralEnabledEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ReserveUsedAsCollateralEnabled');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ReserveUsedAsCollateralEnabled(decoded);
    });
  }

  /// Returns a live stream of all Swap events emitted by this contract.
  Stream<Swap> swapEvents({_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Swap');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Swap(decoded);
    });
  }

  /// Returns a live stream of all Unpaused events emitted by this contract.
  Stream<Unpaused> unpausedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Unpaused');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Unpaused(decoded);
    });
  }

  /// Returns a live stream of all Withdraw events emitted by this contract.
  Stream<Withdraw> withdrawEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Withdraw');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Withdraw(decoded);
    });
  }
}

class GetUserAccountData {
  GetUserAccountData(List<dynamic> response)
      : totalCollateralETH = (response[0] as BigInt),
        totalDebtETH = (response[1] as BigInt),
        availableBorrowsETH = (response[2] as BigInt),
        currentLiquidationThreshold = (response[3] as BigInt),
        ltv = (response[4] as BigInt),
        healthFactor = (response[5] as BigInt);

  final BigInt totalCollateralETH;

  final BigInt totalDebtETH;

  final BigInt availableBorrowsETH;

  final BigInt currentLiquidationThreshold;

  final BigInt ltv;

  final BigInt healthFactor;
}

class Borrow {
  Borrow(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress),
        onBehalfOf = (response[2] as _i1.EthereumAddress),
        amount = (response[3] as BigInt),
        borrowRateMode = (response[4] as BigInt),
        borrowRate = (response[5] as BigInt),
        referral = (response[6] as BigInt);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;

  final _i1.EthereumAddress onBehalfOf;

  final BigInt amount;

  final BigInt borrowRateMode;

  final BigInt borrowRate;

  final BigInt referral;
}

class Deposit {
  Deposit(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress),
        onBehalfOf = (response[2] as _i1.EthereumAddress),
        amount = (response[3] as BigInt),
        referral = (response[4] as BigInt);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;

  final _i1.EthereumAddress onBehalfOf;

  final BigInt amount;

  final BigInt referral;
}

class FlashLoan {
  FlashLoan(List<dynamic> response)
      : target = (response[0] as _i1.EthereumAddress),
        initiator = (response[1] as _i1.EthereumAddress),
        asset = (response[2] as _i1.EthereumAddress),
        amount = (response[3] as BigInt),
        premium = (response[4] as BigInt),
        referralCode = (response[5] as BigInt);

  final _i1.EthereumAddress target;

  final _i1.EthereumAddress initiator;

  final _i1.EthereumAddress asset;

  final BigInt amount;

  final BigInt premium;

  final BigInt referralCode;
}

class LiquidationCall {
  LiquidationCall(List<dynamic> response)
      : collateralAsset = (response[0] as _i1.EthereumAddress),
        debtAsset = (response[1] as _i1.EthereumAddress),
        user = (response[2] as _i1.EthereumAddress),
        debtToCover = (response[3] as BigInt),
        liquidatedCollateralAmount = (response[4] as BigInt),
        liquidator = (response[5] as _i1.EthereumAddress),
        receiveAToken = (response[6] as bool);

  final _i1.EthereumAddress collateralAsset;

  final _i1.EthereumAddress debtAsset;

  final _i1.EthereumAddress user;

  final BigInt debtToCover;

  final BigInt liquidatedCollateralAmount;

  final _i1.EthereumAddress liquidator;

  final bool receiveAToken;
}

class Paused {
  Paused(List<dynamic> response);
}

class RebalanceStableBorrowRate {
  RebalanceStableBorrowRate(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;
}

class Repay {
  Repay(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress),
        repayer = (response[2] as _i1.EthereumAddress),
        amount = (response[3] as BigInt);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;

  final _i1.EthereumAddress repayer;

  final BigInt amount;
}

class ReserveDataUpdated {
  ReserveDataUpdated(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        liquidityRate = (response[1] as BigInt),
        stableBorrowRate = (response[2] as BigInt),
        variableBorrowRate = (response[3] as BigInt),
        liquidityIndex = (response[4] as BigInt),
        variableBorrowIndex = (response[5] as BigInt);

  final _i1.EthereumAddress reserve;

  final BigInt liquidityRate;

  final BigInt stableBorrowRate;

  final BigInt variableBorrowRate;

  final BigInt liquidityIndex;

  final BigInt variableBorrowIndex;
}

class ReserveUsedAsCollateralDisabled {
  ReserveUsedAsCollateralDisabled(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;
}

class ReserveUsedAsCollateralEnabled {
  ReserveUsedAsCollateralEnabled(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;
}

class Swap {
  Swap(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress),
        rateMode = (response[2] as BigInt);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;

  final BigInt rateMode;
}

class Unpaused {
  Unpaused(List<dynamic> response);
}

class Withdraw {
  Withdraw(List<dynamic> response)
      : reserve = (response[0] as _i1.EthereumAddress),
        user = (response[1] as _i1.EthereumAddress),
        to = (response[2] as _i1.EthereumAddress),
        amount = (response[3] as BigInt);

  final _i1.EthereumAddress reserve;

  final _i1.EthereumAddress user;

  final _i1.EthereumAddress to;

  final BigInt amount;
}
