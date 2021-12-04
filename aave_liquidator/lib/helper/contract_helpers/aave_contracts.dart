import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool_address_provider.g.dart';
import 'package:aave_liquidator/abi/aave_abi/aave_price_oracle.g.dart';
import 'package:aave_liquidator/abi/aave_abi/aave_protocol_data_provider.g.dart';
import 'package:aave_liquidator/configs/config.dart';
import 'package:aave_liquidator/services/web3_service.dart';
import 'package:web3dart/web3dart.dart';

class AaveContracts {
  AaveContracts(Web3Service web3, Config config) {
    _web3service = web3;
    _config = config;
    _setupAddressProviderContract();
  }
  late Config _config;
  late Web3Service _web3service;
  late Aave_lending_pool_address_provider aaveAddressProviderContract;
  late Aave_lending_pool lendingPoolContract;
  late DeployedContract proxyContract;
  late Aave_protocol_data_provider protocolDataProviderContract;
  late Aave_price_oracle aavePriceProvider;

  late ContractEvent contractDepositEvent;
  late ContractEvent contractWithdrawEvent;
  late ContractEvent contractBorrowEvent;
  late ContractEvent contractRepayEvent;
  late ContractEvent contractLiquidationCallEvent;

  late EthereumAddress lendingPoolProxyAddress;
  late EthereumAddress protocolDataProviderAdress;
  late EthereumAddress priceOracleAddress;

  _setupAddressProviderContract() async {
    aaveAddressProviderContract = Aave_lending_pool_address_provider(
        address: _config.lendingPoolAddressProviderContractAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId);

    lendingPoolProxyAddress =
        await aaveAddressProviderContract.getLendingPool();
    protocolDataProviderAdress = _config
        .protocolDataProviderContractAddress; // await aaveAddressProviderContract.getAddress(0x1);
    priceOracleAddress = await aaveAddressProviderContract.getPriceOracle();
    _setupContracts();
  }

  _setupContracts() {
    lendingPoolContract = Aave_lending_pool(
        address: lendingPoolProxyAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId);

    protocolDataProviderContract = Aave_protocol_data_provider(
        address: protocolDataProviderAdress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId);

    aavePriceProvider = Aave_price_oracle(
        address: priceOracleAddress, // _config.aavePriceOracleContractAddress,
        client: _web3service.web3Client,
        chainId: _web3service.chainId);

    /// setup contract events
    contractDepositEvent = lendingPoolContract.self.event('Deposit');
    contractWithdrawEvent = lendingPoolContract.self.event('Withdraw');
    contractBorrowEvent = lendingPoolContract.self.event('Borrow');
    contractRepayEvent = lendingPoolContract.self.event('Repay');
    contractLiquidationCallEvent =
        lendingPoolContract.self.event('LiquidationCall');
  }
}
