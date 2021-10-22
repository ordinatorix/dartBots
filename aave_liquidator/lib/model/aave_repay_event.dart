class AaveRepayEvent {
  String reserve;
  String userAddress;
  String onBehalfOf;
  double amount;
  AaveRepayEvent({
    required this.reserve,
    required this.userAddress,
    required this.onBehalfOf,
    required this.amount,
  });
  @override
  String toString() {
    return 'Repay Event:\n  Reserve:$reserve;\n User: $userAddress;\n onBehalfOf: $onBehalfOf;\n Repayed amount: $amount;';
  }
}
