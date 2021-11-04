// import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
// import 'package:aave_liquidator/logger.dart';
// import 'package:web3dart/web3dart.dart';

// final log = getLogger('AaveLendingPoolEventListeners');

// class AaveLendingPoolEventListeners {
//   late Aave_lending_pool lendingPoolContract;
//   late ContractEvent contractDepositEvent;
//   late ContractEvent contractWithdrawEvent;
//   late ContractEvent contractBorrowEvent;
//   late ContractEvent contractRepayEvent;
//   late ContractEvent contractLiquidationCallEvent;

//   /// Setup contract
//   _setupContract() {
//     lendingPoolContract = Aave_lending_pool(
//         address: _config.lendingPoolProxyContractAddress,
//         client: web3Client,
//         chainId: chainId);

//     /// setup contract events
//     contractDepositEvent = lendingPoolContract.self.event('Deposit');
//     contractWithdrawEvent = lendingPoolContract.self.event('Withdraw');
//     contractBorrowEvent = lendingPoolContract.self.event('Borrow');
//     contractRepayEvent = lendingPoolContract.self.event('Repay');
//     contractLiquidationCallEvent =
//         lendingPoolContract.self.event('LiquidationCall');
//   }

//   /// Listen for borrow events.
//   /// TODO: for any user in db
//   /// update user data.
//   _listenForBorrowEvents() {
//     log.i('listenning for borrow event');

//     lendingPoolContract.borrowEvents().listen((_borrow) {
//       log.d('new borrow event: $_borrow');
//       _parseEventToAaveBorrowEvent(borrow: _borrow);
//     });
//   }

//   /// Listen for deposit events.
//   /// TODO: for any user in db
//   /// update user data
//   _listenForDepositEvent() {
//     log.i('listenning for deposit event');

//     lendingPoolContract.depositEvents().listen((_deposit) {
//       log.d('new deposit event: $_deposit');

//       _parseEventToAaveDepositEvent(deposit: _deposit);
//     });
//   }

//   /// listen for repay event
//   /// TODO: for any event from user in db,
//   /// update user data.
//   _listenForRepayEvent() {
//     log.i('listenning for repay event');

//     lendingPoolContract.repayEvents().listen((_repay) {
//       log.d('new repay event: $_repay');
//       _parseEventToAaveRepayEvent(repay: _repay);
//     });
//   }

//   /// listen for withdraw event
//   /// TODO: for any user in db
//   /// update user data.
//   _listenForWithdrawEvent() {
//     log.i('listenning for withdraw event');
//     lendingPoolContract.withdrawEvents().listen((_withdraw) {
//       log.d('new withdraw event: $_withdraw');
//       _parseEventToAaveWithdrawEvent(withdraw: _withdraw);
//     });
//   }

//   /// listen for liquidation call events
//   /// TODO:

//   _listenForLiquidationcall() {
//     log.i('listenning for liquidation call events');
//     lendingPoolContract.liquidationCallEvents().listen((_liqCall) {
//       log.d('new liquidation call event: $_liqCall');
//       // TODO: parse liquidation call event.
//     });
//   }
// }
