class AaveWidthdrawEvent {
  String reserve;
  String userAddress;
  String to;
  double amount;

  AaveWidthdrawEvent({
    required this.reserve,
    required this.userAddress,
    required this.to,
    required this.amount,
  });

  @override
  String toString() {
    return 'WidthdrawalEvent:\n Reserve:$reserve;\n User: $userAddress;\n onBehalfOf: $to;\n Amount: $amount.';
  }
}
