import '../../../features/pin/view/pin_page.dart';

class SharedDataService {
  WithdrawalData? _data;

  WithdrawalData? get data => _data;

  set data(WithdrawalData? value) {
    _data = value;
  }

  void clearData() {
    _data = null;
  }
}
