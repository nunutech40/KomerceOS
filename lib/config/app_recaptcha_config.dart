class AppRecaptchaConfig {
  final String androidSiteKey;
  final String iosSiteKey;
  AppRecaptchaConfig(this.androidSiteKey, this.iosSiteKey);

  static Future<AppRecaptchaConfig> forEnvironment(String? env) async {
    final flavor =
        env ?? const String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    if (flavor == 'production') {
      return AppRecaptchaConfig(
        "6Lfzp4EtAAAAAKS40nm6gh3_irkwGpBXAFlHt5Z3",
        "YOUR_IOS_SITE_KEY",
      );
    } else if (flavor == 'staging') {
      return AppRecaptchaConfig(
        // Staging temporarily shares the dev key to match BE validation.
        "6LfuqxIsAAAAADO9NHf0LBNzzJQ7mHTvSt_8a7Hx",
        "YOUR_IOS_SITE_KEY",
      );
    }

    // Default / dev
    return AppRecaptchaConfig(
      "6LfuqxIsAAAAADO9NHf0LBNzzJQ7mHTvSt_8a7Hx",
      "YOUR_IOS_SITE_KEY",
    );
  }
}
