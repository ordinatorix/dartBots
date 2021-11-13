class AaveRepayEvent {
  String reserve;
  String userAddress;
  String repayer;
  BigInt amount;
  AaveRepayEvent({
    required this.reserve,
    required this.userAddress,
    required this.repayer,
    required this.amount,
  });
  @override
  String toString() {
    return 'Repay Event: Reserve:$reserve; User: $userAddress; repayer: $repayer; Repayed amount: $amount;';
  }
}
