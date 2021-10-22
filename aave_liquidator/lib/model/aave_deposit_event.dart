class AaveDepositEvent {
  String reserve;
  String userAddress;
  String onBehalfOf;
  double amount;

  AaveDepositEvent({
    required this.reserve,
    required this.userAddress,
    required this.onBehalfOf,
    required this.amount,
  });

  @override
  String toString() {
    return 'DepositEvent:\n Reserve:$reserve;\n User: $userAddress;\n onBehalfOf: $onBehalfOf;\n Amount: $amount.';
  }
}
