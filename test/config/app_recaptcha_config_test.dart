import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/config/app_recaptcha_config.dart';

void main() {
  test('staging reCAPTCHA Android key matches dev, production stays separate',
      () async {
    final dev = await AppRecaptchaConfig.forEnvironment('dev');
    final staging = await AppRecaptchaConfig.forEnvironment('staging');
    final production = await AppRecaptchaConfig.forEnvironment('production');

    expect(staging.androidSiteKey, dev.androidSiteKey);
    expect(production.androidSiteKey, isNot(dev.androidSiteKey));
    expect(staging.iosSiteKey, dev.iosSiteKey);
  });
}
