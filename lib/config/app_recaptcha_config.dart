class AppRecaptchaConfig {
  final String androidSiteKey;
  final String iosSiteKey;
  AppRecaptchaConfig(this.androidSiteKey, this.iosSiteKey);

  static Future<AppRecaptchaConfig> forEnvironment(String? env) async {
    const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    if (flavor == 'production') {
      return AppRecaptchaConfig(
        "6Lfzp4EtAAAAAKS40nm6gh3_irkwGpBXAFlHt5Z3",
        "YOUR_IOS_SITE_KEY",
      );
    } else if (flavor == 'staging') {
      return AppRecaptchaConfig(
        "6Lf-J0wtAAAAAKb1A7msYBRbJICXYQ1qkBTWpjdT",
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
