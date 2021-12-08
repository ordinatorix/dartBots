// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"inputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"addressesProvider","type":"address"},{"internalType":"contract IUniswapV2Router02","name":"uniswapRouter","type":"address"},{"internalType":"address","name":"wethAddress","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"fromAsset","type":"address"},{"indexed":false,"internalType":"address","name":"toAsset","type":"address"},{"indexed":false,"internalType":"uint256","name":"fromAmount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"receivedAmount","type":"uint256"}],"name":"Swapped","type":"event"},{"inputs":[],"name":"ADDRESSES_PROVIDER","outputs":[{"internalType":"contract ILendingPoolAddressesProvider","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"FLASHLOAN_PREMIUM_TOTAL","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"LENDING_POOL","outputs":[{"internalType":"contract ILendingPool","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"MAX_SLIPPAGE_PERCENT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"ORACLE","outputs":[{"internalType":"contract IPriceOracleGetter","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"UNISWAP_ROUTER","outputs":[{"internalType":"contract IUniswapV2Router02","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"USD_ADDRESS","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"WETH_ADDRESS","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"assets","type":"address[]"},{"internalType":"uint256[]","name":"amounts","type":"uint256[]"},{"internalType":"uint256[]","name":"premiums","type":"uint256[]"},{"internalType":"address","name":"initiator","type":"address"},{"internalType":"bytes","name":"parametres","type":"bytes"}],"name":"executeOperation","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountOut","type":"uint256"},{"internalType":"address","name":"reserveIn","type":"address"},{"internalType":"address","name":"reserveOut","type":"address"}],"name":"getAmountsIn","outputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amountIn","type":"uint256"},{"internalType":"address","name":"reserveIn","type":"address"},{"internalType":"address","name":"reserveOut","type":"address"}],"name":"getAmountsOut","outputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"address[]","name":"","type":"address[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"assets","type":"address[]"},{"internalType":"uint256[]","name":"amounts","type":"uint256[]"},{"internalType":"uint256[]","name":"modes","type":"uint256[]"},{"internalType":"bytes","name":"parametres","type":"bytes"}],"name":"requestFlashLoan","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"contract IERC20","name":"token","type":"address"}],"name":"rescueTokens","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
    'Liquidator');

class Liquidator extends _i1.GeneratedContract {
  Liquidator(
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
  Future<BigInt> FLASHLOAN_PREMIUM_TOTAL({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    assert(checkSignature(function, '074b2e43'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> LENDING_POOL({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[3];
    assert(checkSignature(function, 'b4dcfc77'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> MAX_SLIPPAGE_PERCENT({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[4];
    assert(checkSignature(function, '32e4b286'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> ORACLE({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[5];
    assert(checkSignature(function, '38013f02'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> UNISWAP_ROUTER({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[6];
    assert(checkSignature(function, 'd8264920'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> USD_ADDRESS({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[7];
    assert(checkSignature(function, '9d1211bf'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> WETH_ADDRESS({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[8];
    assert(checkSignature(function, '040141e5'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> executeOperation(
      List<_i1.EthereumAddress> assets,
      List<BigInt> amounts,
      List<BigInt> premiums,
      _i1.EthereumAddress initiator,
      _i2.Uint8List parametres,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[9];
    assert(checkSignature(function, '920f5c84'));
    final params = [assets, amounts, premiums, initiator, parametres];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetAmountsIn> getAmountsIn(BigInt amountOut,
      _i1.EthereumAddress reserveIn, _i1.EthereumAddress reserveOut,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[10];
    assert(checkSignature(function, 'cdf58cd6'));
    final params = [amountOut, reserveIn, reserveOut];
    final response = await read(function, params, atBlock);
    return GetAmountsIn(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetAmountsOut> getAmountsOut(BigInt amountIn,
      _i1.EthereumAddress reserveIn, _i1.EthereumAddress reserveOut,
      {_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[11];
    assert(checkSignature(function, 'baf7fa99'));
    final params = [amountIn, reserveIn, reserveOut];
    final response = await read(function, params, atBlock);
    return GetAmountsOut(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> owner({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[12];
    assert(checkSignature(function, '8da5cb5b'));
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> renounceOwnership(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[13];
    assert(checkSignature(function, '715018a6'));
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> requestFlashLoan(List<_i1.EthereumAddress> assets,
      List<BigInt> amounts, List<BigInt> modes, _i2.Uint8List parametres,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[14];
    assert(checkSignature(function, 'e347d53e'));
    final params = [assets, amounts, modes, parametres];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> rescueTokens(_i1.EthereumAddress token,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[15];
    assert(checkSignature(function, '00ae3bf8'));
    final params = [token];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transferOwnership(_i1.EthereumAddress newOwner,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[16];
    assert(checkSignature(function, 'f2fde38b'));
    final params = [newOwner];
    return write(credentials, transaction, function, params);
  }

  /// Returns a live stream of all OwnershipTransferred events emitted by this contract.
  Stream<OwnershipTransferred> ownershipTransferredEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('OwnershipTransferred');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return OwnershipTransferred(decoded);
    });
  }

  /// Returns a live stream of all Swapped events emitted by this contract.
  Stream<Swapped> swappedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Swapped');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Swapped(decoded);
    });
  }
}

class GetAmountsIn {
  GetAmountsIn(List<dynamic> response)
      : var1 = (response[0] as BigInt),
        var2 = (response[1] as BigInt),
        var3 = (response[2] as BigInt),
        var4 = (response[3] as BigInt),
        var5 = (response[4] as List<dynamic>).cast<_i1.EthereumAddress>();

  final BigInt var1;

  final BigInt var2;

  final BigInt var3;

  final BigInt var4;

  final List<_i1.EthereumAddress> var5;
}

class GetAmountsOut {
  GetAmountsOut(List<dynamic> response)
      : var1 = (response[0] as BigInt),
        var2 = (response[1] as BigInt),
        var3 = (response[2] as BigInt),
        var4 = (response[3] as BigInt),
        var5 = (response[4] as List<dynamic>).cast<_i1.EthereumAddress>();

  final BigInt var1;

  final BigInt var2;

  final BigInt var3;

  final BigInt var4;

  final List<_i1.EthereumAddress> var5;
}

class OwnershipTransferred {
  OwnershipTransferred(List<dynamic> response)
      : previousOwner = (response[0] as _i1.EthereumAddress),
        newOwner = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress previousOwner;

  final _i1.EthereumAddress newOwner;
}

class Swapped {
  Swapped(List<dynamic> response)
      : fromAsset = (response[0] as _i1.EthereumAddress),
        toAsset = (response[1] as _i1.EthereumAddress),
        fromAmount = (response[2] as BigInt),
        receivedAmount = (response[3] as BigInt);

  final _i1.EthereumAddress fromAsset;

  final _i1.EthereumAddress toAsset;

  final BigInt fromAmount;

  final BigInt receivedAmount;
}
