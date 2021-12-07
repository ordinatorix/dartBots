class AaveBorrowEvent {
  String reserve;
  String userAddress;
  String onBehalfOf;
  BigInt amount;
  BigInt borrowRateMode;
  BigInt borrowRate;

  AaveBorrowEvent({
    required this.reserve,
    required this.userAddress,
    required this.onBehalfOf,
    required this.amount,
    required this.borrowRateMode,
    required this.borrowRate,
  });
  @override
  String toString() {
    return 'Borrow Event:\n  Reserve:$reserve;\n User: $userAddress;\n onBehalfOf: $onBehalfOf;\n Borrow amount: $amount;\n borrow rate mode: $borrowRateMode;\n borrow Rate: $borrowRate.';
  }
}
