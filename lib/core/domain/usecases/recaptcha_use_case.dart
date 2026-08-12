import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/config/app_recaptcha_config.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';

class RecaptchaUseCase {
  RecaptchaClient? _client;
  bool _isInitialized = false;

  String _getSiteKey(AppRecaptchaConfig config) {
    return Platform.isAndroid ? config.androidSiteKey : config.iosSiteKey;
  }

  bool get isInitialized => _isInitialized;

  Future<void> initializeClient() async {
    final config = await AppRecaptchaConfig.forEnvironment(null);
    final siteKey = _getSiteKey(config);

    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'NOT_SET');
    debugPrint("RECAPTCHA_DEBUG: Current FLAVOR environment: $flavor");
    debugPrint(
        "RECAPTCHA_DEBUG: Initializing reCAPTCHA with SiteKey: $siteKey");

    try {
      _client = await Recaptcha.fetchClient(siteKey);
      _isInitialized = true;
    } on PlatformException {
      _isInitialized = true;
      rethrow;
    } catch (err) {
      _isInitialized = true;
      rethrow;
    }
  }

  Future<String> getToken(RecaptchaAction action) async {
    if (_client == null) {
      throw Exception(
          "reCAPTCHA Client not initialized. Call initializeClient() first.");
    }

    try {
      final token = await _client!.execute(action);
      return token;
    } on PlatformException {
      rethrow;
    } catch (err) {
      rethrow;
    }
  }
}
