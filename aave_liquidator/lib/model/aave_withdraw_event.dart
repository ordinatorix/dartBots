class AaveWithdrawEvent {
  String reserve;
  String userAddress;
  String to;
  double amount;

  AaveWithdrawEvent({
    required this.reserve,
    required this.userAddress,
    required this.to,
    required this.amount,
  });

  @override
  String toString() {
    return 'WithdrawalEvent:\n Reserve:$reserve;\n User: $userAddress;\n onBehalfOf: $to;\n Amount: $amount.';
  }
}
