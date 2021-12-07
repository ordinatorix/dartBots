import 'dart:convert';
import 'dart:io';

int requireNetworkSelection() {
  /// prompt user to select network.
  print(
      'Select Network:\n 0:local network\n 1:kovan testnet\n 2:Mainnet\n 3:Polygon\n 4:Avalanche');
  String? _userInput = stdin.readLineSync(encoding: utf8);

  if (_userInput != null && _userInput.isNotEmpty) {
    return int.parse(_userInput.trim());
  } else {
    print('invalid answer. Please review documentation.');

    exit(1);
  }
}
