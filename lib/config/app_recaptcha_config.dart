class AppRecaptchaConfig {
  static const String _iosSiteKey =
      String.fromEnvironment('RECAPTCHA_IOS_SITE_KEY');

  final String androidSiteKey;
  final String iosSiteKey;
  AppRecaptchaConfig(this.androidSiteKey, this.iosSiteKey);

  static Future<AppRecaptchaConfig> forEnvironment(String? env) async {
    final flavor =
        env ?? const String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    if (flavor == 'production') {
      return AppRecaptchaConfig(
        "6Lfzp4EtAAAAAKS40nm6gh3_irkwGpBXAFlHt5Z3",
        _iosSiteKey,
      );
    } else if (flavor == 'staging') {
      return AppRecaptchaConfig(
        "6LfuqxIsAAAAADO9NHf0LBNzzJQ7mHTvSt_8a7Hx",
        _iosSiteKey,
      );
    }

    // Default / dev
    return AppRecaptchaConfig(
      "6LfuqxIsAAAAADO9NHf0LBNzzJQ7mHTvSt_8a7Hx",
      _iosSiteKey,
    );
  }
}
