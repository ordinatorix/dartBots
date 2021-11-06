import 'package:aave_liquidator/abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/contract_helpers/aave_contracts.dart';
import 'package:aave_liquidator/logger.dart';
import 'package:aave_liquidator/model/aave_borrow_event.dart';
import 'package:aave_liquidator/model/aave_deposit_event.dart';
import 'package:aave_liquidator/model/aave_repay_event.dart';
import 'package:aave_liquidator/model/aave_withdraw_event.dart';
import 'package:web3dart/web3dart.dart';

final log = getLogger('AaveEventParser');

class AaveEventParser {
  AaveEventParser(AaveContracts aaveContracts) {
    _aaveContracts = aaveContracts;
  }
  late AaveContracts _aaveContracts;

  /// parse borrow event data and topics
  AaveBorrowEvent parseEventToAaveBorrowEvent(
      {Borrow? borrow, FilterEvent? filterEvent}) {
    log.v('parsing borrow event');
    late AaveBorrowEvent parsedBorrowEvent;
    if (filterEvent != null) {
      final List _decodedResult = _aaveContracts.contractBorrowEvent
          .decodeResults(filterEvent.topics!, filterEvent.data!);
      parsedBorrowEvent = AaveBorrowEvent(
        userAddress: _decodedResult[1].toString(),
        onBehalfOf: _decodedResult[2].toString(),
        reserve: _decodedResult[0].toString(),
        amount: double.parse(_decodedResult[3].toString()),
        borrowRateMode: double.parse(_decodedResult[4].toString()),
        borrowRate: double.parse(_decodedResult[5].toString()),
      );
    } else {
      parsedBorrowEvent = AaveBorrowEvent(
        userAddress: borrow!.user.toString(),
        onBehalfOf: borrow.onBehalfOf.toString(),
        reserve: borrow.reserve.toString(),
        amount: borrow.amount.toDouble(),
        borrowRateMode: borrow.borrowRateMode.toDouble(),
        borrowRate: borrow.borrowRate.toDouble(),
      );
    }

    return parsedBorrowEvent;
  }

  /// Parse deposit event data and topics.
  AaveDepositEvent parseEventToAaveDepositEvent(
      {Deposit? deposit, FilterEvent? filterEvent}) {
    log.v('parsing deposit event');
    late AaveDepositEvent parsedDepositEvent;
    if (filterEvent != null) {
      final List _decodedResult = _aaveContracts.contractDepositEvent
          .decodeResults(filterEvent.topics!, filterEvent.data!);

      parsedDepositEvent = AaveDepositEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        onBehalfOf: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedDepositEvent = AaveDepositEvent(
        reserve: deposit!.reserve.toString(),
        userAddress: deposit.user.toString(),
        onBehalfOf: deposit.onBehalfOf.toString(),
        amount: deposit.amount.toDouble(),
      );
    }

    return parsedDepositEvent;
  }

  /// Parse repay event
  AaveRepayEvent parseEventToAaveRepayEvent(
      {Repay? repay, FilterEvent? filterEvent}) {
    log.v('parsing repay event: $filterEvent');
    late AaveRepayEvent parsedRepayEvent;
    if (filterEvent != null) {
      final List _decodedResult = _aaveContracts.contractRepayEvent
          .decodeResults(filterEvent.topics!, filterEvent.data!);

      parsedRepayEvent = AaveRepayEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        repayer: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedRepayEvent = AaveRepayEvent(
        reserve: repay!.reserve.toString(),
        userAddress: repay.user.toString(),
        repayer: repay.repayer.toString(),
        amount: repay.amount.toDouble(),
      );
    }

    return parsedRepayEvent;
  }

  /// Parse withdraw event.
  AaveWithdrawEvent parseEventToAaveWithdrawEvent(
      {Withdraw? withdraw, FilterEvent? filterEvent}) {
    log.d('parsing withdraw event');
    late AaveWithdrawEvent parsedWithdrawEvent;
    if (filterEvent != null) {
      List _decodedResult = _aaveContracts.contractWithdrawEvent
          .decodeResults(filterEvent.topics!, filterEvent.data!);

      log.d('decoded withdraw event: $_decodedResult');
      parsedWithdrawEvent = AaveWithdrawEvent(
        reserve: _decodedResult[0].toString(),
        userAddress: _decodedResult[1].toString(),
        to: _decodedResult[2].toString(),
        amount: double.parse(_decodedResult[3].toString()),
      );
    } else {
      parsedWithdrawEvent = AaveWithdrawEvent(
        reserve: withdraw!.reserve.toString(),
        userAddress: withdraw.user.toString(),
        to: withdraw.to.toString(),
        amount: withdraw.amount.toDouble(),
      );
    }
    log.d(parsedWithdrawEvent);
    return parsedWithdrawEvent;
  }
}
