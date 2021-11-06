// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"inputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"addressesProvider","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"ADDRESSES_PROVIDER","outputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAllATokens","outputs":[{"components":[{"internalType":"string","name":"symbol","type":"string"},{"internalType":"address","name":"tokenAddress","type":"address"}],"internalType":"struct AaveProtocolDataProvider.TokenData[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAllReservesTokens","outputs":[{"components":[{"internalType":"string","name":"symbol","type":"string"},{"internalType":"address","name":"tokenAddress","type":"address"}],"internalType":"struct AaveProtocolDataProvider.TokenData[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveConfigurationData","outputs":[{"internalType":"uint256","name":"decimals","type":"uint256"},{"internalType":"uint256","name":"ltv","type":"uint256"},{"internalType":"uint256","name":"liquidationThreshold","type":"uint256"},{"internalType":"uint256","name":"liquidationBonus","type":"uint256"},{"internalType":"uint256","name":"reserveFactor","type":"uint256"},{"internalType":"bool","name":"usageAsCollateralEnabled","type":"bool"},{"internalType":"bool","name":"borrowingEnabled","type":"bool"},{"internalType":"bool","name":"stableBorrowRateEnabled","type":"bool"},{"internalType":"bool","name":"isActive","type":"bool"},{"internalType":"bool","name":"isFrozen","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveData","outputs":[{"internalType":"uint256","name":"availableLiquidity","type":"uint256"},{"internalType":"uint256","name":"totalStableDebt","type":"uint256"},{"internalType":"uint256","name":"totalVariableDebt","type":"uint256"},{"internalType":"uint256","name":"liquidityRate","type":"uint256"},{"internalType":"uint256","name":"variableBorrowRate","type":"uint256"},{"internalType":"uint256","name":"stableBorrowRate","type":"uint256"},{"internalType":"uint256","name":"averageStableBorrowRate","type":"uint256"},{"internalType":"uint256","name":"liquidityIndex","type":"uint256"},{"internalType":"uint256","name":"variableBorrowIndex","type":"uint256"},{"internalType":"uint40","name":"lastUpdateTimestamp","type":"uint40"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"}],"name":"getReserveTokensAddresses","outputs":[{"internalType":"address","name":"aTokenAddress","type":"address"},{"internalType":"address","name":"stableDebtTokenAddress","type":"address"},{"internalType":"address","name":"variableDebtTokenAddress","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"asset","type":"address"},{"internalType":"address","name":"user","type":"address"}],"name":"getUserReserveData","outputs":[{"internalType":"uint256","name":"currentATokenBalance","type":"uint256"},{"internalType":"uint256","name":"currentStableDebt","type":"uint256"},{"internalType":"uint256","name":"currentVariableDebt","type":"uint256"},{"internalType":"uint256","name":"principalStableDebt","type":"uint256"},{"internalType":"uint256","name":"scaledVariableDebt","type":"uint256"},{"internalType":"uint256","name":"stableBorrowRate","type":"uint256"},{"internalType":"uint256","name":"liquidityRate","type":"uint256"},{"internalType":"uint40","name":"stableRateLastUpdated","type":"uint40"},{"internalType":"bool","name":"usageAsCollateralEnabled","type":"bool"}],"stateMutability":"view","type":"function"}]',
    'Aave_protocol_data_provider');

class Aave_protocol_data_provider extends _i1.GeneratedContract {
  Aave_protocol_data_provider(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> ADDRESSES_PROVIDER(
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '0542975c'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getAllATokens({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, 'f561ae41'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<List<dynamic>> getAllReservesTokens({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'b316ff89'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as List<dynamic>).cast<dynamic>();
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetReserveConfigurationData> getReserveConfigurationData(
      _i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '3e150141'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return GetReserveConfigurationData(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetReserveData> getReserveData(_i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '35ea6a75'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return GetReserveData(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetReserveTokensAddresses> getReserveTokensAddresses(
      _i1.EthereumAddress asset,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'd2493b6c'));
    final params = [asset];
    final response = await read(function, params, atBlock);
    return GetReserveTokensAddresses(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetUserReserveData> getUserReserveData(
      _i1.EthereumAddress asset, _i1.EthereumAddress user,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '28dd2d01'));
    final params = [asset, user];
    final response = await read(function, params, atBlock);
    return GetUserReserveData(response);
  }
}

class GetReserveConfigurationData {
  GetReserveConfigurationData(List<dynamic> response)
      : decimals = (response[0] as BigInt),
        ltv = (response[1] as BigInt),
        liquidationThreshold = (response[2] as BigInt),
        liquidationBonus = (response[3] as BigInt),
        reserveFactor = (response[4] as BigInt),
        usageAsCollateralEnabled = (response[5] as bool),
        borrowingEnabled = (response[6] as bool),
        stableBorrowRateEnabled = (response[7] as bool),
        isActive = (response[8] as bool),
        isFrozen = (response[9] as bool);

  final BigInt decimals;

  final BigInt ltv;

  final BigInt liquidationThreshold;

  final BigInt liquidationBonus;

  final BigInt reserveFactor;

  final bool usageAsCollateralEnabled;

  final bool borrowingEnabled;

  final bool stableBorrowRateEnabled;

  final bool isActive;

  final bool isFrozen;
}

class GetReserveData {
  GetReserveData(List<dynamic> response)
      : availableLiquidity = (response[0] as BigInt),
        totalStableDebt = (response[1] as BigInt),
        totalVariableDebt = (response[2] as BigInt),
        liquidityRate = (response[3] as BigInt),
        variableBorrowRate = (response[4] as BigInt),
        stableBorrowRate = (response[5] as BigInt),
        averageStableBorrowRate = (response[6] as BigInt),
        liquidityIndex = (response[7] as BigInt),
        variableBorrowIndex = (response[8] as BigInt),
        lastUpdateTimestamp = (response[9] as BigInt);

  final BigInt availableLiquidity;

  final BigInt totalStableDebt;

  final BigInt totalVariableDebt;

  final BigInt liquidityRate;

  final BigInt variableBorrowRate;

  final BigInt stableBorrowRate;

  final BigInt averageStableBorrowRate;

  final BigInt liquidityIndex;

  final BigInt variableBorrowIndex;

  final BigInt lastUpdateTimestamp;
}

class GetReserveTokensAddresses {
  GetReserveTokensAddresses(List<dynamic> response)
      : aTokenAddress = (response[0] as _i1.EthereumAddress),
        stableDebtTokenAddress = (response[1] as _i1.EthereumAddress),
        variableDebtTokenAddress = (response[2] as _i1.EthereumAddress);

  final _i1.EthereumAddress aTokenAddress;

  final _i1.EthereumAddress stableDebtTokenAddress;

  final _i1.EthereumAddress variableDebtTokenAddress;
}

class GetUserReserveData {
  GetUserReserveData(List<dynamic> response)
      : currentATokenBalance = (response[0] as BigInt),
        currentStableDebt = (response[1] as BigInt),
        currentVariableDebt = (response[2] as BigInt),
        principalStableDebt = (response[3] as BigInt),
        scaledVariableDebt = (response[4] as BigInt),
        stableBorrowRate = (response[5] as BigInt),
        liquidityRate = (response[6] as BigInt),
        stableRateLastUpdated = (response[7] as BigInt),
        usageAsCollateralEnabled = (response[8] as bool);

  final BigInt currentATokenBalance;

  final BigInt currentStableDebt;

  final BigInt currentVariableDebt;

  final BigInt principalStableDebt;

  final BigInt scaledVariableDebt;

  final BigInt stableBorrowRate;

  final BigInt liquidityRate;

  final BigInt stableRateLastUpdated;

  final bool usageAsCollateralEnabled;
}
