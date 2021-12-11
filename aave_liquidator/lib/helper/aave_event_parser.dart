import 'package:aave_liquidator/abi/aave_abi/aave_lending_pool.g.dart';
import 'package:aave_liquidator/helper/contract_helpers/aave_contracts.dart';
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
      if (filterEvent.topics != null && filterEvent.data != null) {
        final List _decodedResult = _aaveContracts.contractBorrowEvent
            .decodeResults(filterEvent.topics!, filterEvent.data!);
        parsedBorrowEvent = AaveBorrowEvent(
          userAddress: _decodedResult[1].toString(),
          onBehalfOf: _decodedResult[2].toString(),
          reserve: _decodedResult[0].toString(),
          amount: BigInt.parse(_decodedResult[3].toString()),
          borrowRateMode: BigInt.parse(_decodedResult[4].toString()),
          borrowRate: BigInt.parse(_decodedResult[5].toString()),
        );
      } else {
        log.w('topic or data not found this behavior is unexpected');
      }
    } else {
      if (borrow != null) {
        parsedBorrowEvent = AaveBorrowEvent(
          userAddress: borrow.user.toString(),
          onBehalfOf: borrow.onBehalfOf.toString(),
          reserve: borrow.reserve.toString(),
          amount: borrow.amount,
          borrowRateMode: borrow.borrowRateMode,
          borrowRate: borrow.borrowRate,
        );
      } else {
        log.w("borrow event not found. This behavior should not happen");
      }
    }

    return parsedBorrowEvent;
  }

  /// Parse deposit event data and topics.
  AaveDepositEvent parseEventToAaveDepositEvent(
      {Deposit? deposit, FilterEvent? filterEvent}) {
    log.v('parsing deposit event');
    late AaveDepositEvent parsedDepositEvent;
    if (filterEvent != null) {
      if (filterEvent.topics != null && filterEvent.data != null) {
        final List _decodedResult = _aaveContracts.contractDepositEvent
            .decodeResults(filterEvent.topics!, filterEvent.data!);

        parsedDepositEvent = AaveDepositEvent(
          reserve: _decodedResult[0].toString(),
          userAddress: _decodedResult[1].toString(),
          onBehalfOf: _decodedResult[2].toString(),
          amount: BigInt.parse(_decodedResult[3].toString()),
        );
      } else {
        log.w('topic or data not found this behavior is unexpected');
      }
    } else {
      if (deposit != null) {
        parsedDepositEvent = AaveDepositEvent(
          reserve: deposit.reserve.toString(),
          userAddress: deposit.user.toString(),
          onBehalfOf: deposit.onBehalfOf.toString(),
          amount: deposit.amount,
        );
      } else {
        log.w("deposit event not found. This behavior should not happen");
      }
    }

    return parsedDepositEvent;
  }

  /// Parse repay event
  AaveRepayEvent parseEventToAaveRepayEvent(
      {Repay? repay, FilterEvent? filterEvent}) {
    log.v('parsing repay event: $filterEvent');
    late AaveRepayEvent parsedRepayEvent;
    if (filterEvent != null) {
      if (filterEvent.topics != null && filterEvent.data != null) {
        final List _decodedResult = _aaveContracts.contractRepayEvent
            .decodeResults(filterEvent.topics!, filterEvent.data!);

        parsedRepayEvent = AaveRepayEvent(
          reserve: _decodedResult[0].toString(),
          userAddress: _decodedResult[1].toString(),
          repayer: _decodedResult[2].toString(),
          amount: BigInt.parse(_decodedResult[3].toString()),
        );
      } else {
        log.w('topic or data not found this behavior is unexpected');
      }
    } else {
      if (repay != null) {
        parsedRepayEvent = AaveRepayEvent(
          reserve: repay.reserve.toString(),
          userAddress: repay.user.toString(),
          repayer: repay.repayer.toString(),
          amount: repay.amount,
        );
      } else {
        log.w("repay event not found. This behavior should not happen");
      }
    }

    return parsedRepayEvent;
  }

  /// Parse withdraw event.
  AaveWithdrawEvent parseEventToAaveWithdrawEvent(
      {Withdraw? withdraw, FilterEvent? filterEvent}) {
    log.v('parsing withdraw event');
    late AaveWithdrawEvent parsedWithdrawEvent;
    if (filterEvent != null) {
      if (filterEvent.topics != null && filterEvent.data != null) {
        List _decodedResult = _aaveContracts.contractWithdrawEvent
            .decodeResults(filterEvent.topics!, filterEvent.data!);

        parsedWithdrawEvent = AaveWithdrawEvent(
          reserve: _decodedResult[0].toString(),
          userAddress: _decodedResult[1].toString(),
          to: _decodedResult[2].toString(),
          amount: BigInt.parse(_decodedResult[3].toString()),
        );
      } else {
        log.w('topic or data not found this behavior is unexpected');
      }
    } else {
      if (withdraw != null) {
        parsedWithdrawEvent = AaveWithdrawEvent(
          reserve: withdraw.reserve.toString(),
          userAddress: withdraw.user.toString(),
          to: withdraw.to.toString(),
          amount: withdraw.amount,
        );
      } else {
        log.w("withdraw event not found. This behavior should not happen");
      }
    }
    log.v(parsedWithdrawEvent);
    return parsedWithdrawEvent;
  }

  /// ---------------------Aave configs--------------------------------
  /// Encoded topics
  final String encodedBorrowEventTopic =
      '0xc6a898309e823ee50bac64e45ca8adba6690e99e7841c45d754e2a38e9019d9b';
  final String encodedDepositEventTopic =
      '0xde6857219544bb5b7746f48ed30be6386fefc61b2f864cacf559893bf50fd951';
  final String encodedRepayEventTopic =
      '0x4cdde6e09bb755c9a5589ebaec640bbfedff1362d4b255ebf8339782b9942faa';
  final String encodedWithdrawEventTopic =
      '0x3115d1449a7b732c986cba18244e897a450f61e1bb8d589cd2e69e6c8924f9f7';
}
