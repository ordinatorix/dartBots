import 'package:aave_liquidator/web3_service.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> arguments) {
  print('Success, We\'re In!');
  load();
  Web3Service _web3 = Web3Service();

  _web3.dispose();
}
