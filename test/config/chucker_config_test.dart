import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/config/chucker_config.dart';

void main() {
  test('Chucker follows only the dev and staging build flavors', () {
    const flavor = String.fromEnvironment('FLAVOR');
    expect(ChuckerConfig.enabled, flavor == 'dev' || flavor == 'staging');
  });
}
