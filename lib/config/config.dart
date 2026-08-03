import 'package:komtim_partner/config/production.dart';
import 'package:komtim_partner/config/staging.dart';

import 'dev.dart';

abstract class Config {
  String get baseUrl;
  String get baseUrlInternal;
  String get baseUrlTalentPool;
  String get baseUrlWebUrlTalentPool;
  String get baseUrlSuperApp;
  String get baseUrlKomship;

  static Config? _instance;

  static Config get instance {
    if (_instance == null) {
      const String flavor = String.fromEnvironment('FLAVOR');

      if (flavor == 'dev') {
        _instance = DevConfig();
      } else if (flavor == 'staging') {
        _instance = StagingConfig();
      } else if (flavor == 'production') {
        _instance = ProductionConfig();
      } else {
        _instance = ProductionConfig();
      }
    }
    return _instance!;
  }
}
