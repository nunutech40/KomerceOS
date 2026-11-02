import 'dart:async';
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

    if (siteKey.trim().isEmpty || siteKey == 'YOUR_IOS_SITE_KEY') {
      throw StateError('Site key reCAPTCHA iOS belum dikonfigurasi.');
    }

    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'NOT_SET');
    debugPrint("RECAPTCHA_DEBUG: Current FLAVOR environment: $flavor");
    debugPrint('RECAPTCHA_DEBUG: Initializing reCAPTCHA on '
        '${Platform.isIOS ? 'iOS' : 'Android'}');

    try {
      _client = await Recaptcha.fetchClient(siteKey)
          .timeout(const Duration(seconds: 15));
      _isInitialized = true;
    } catch (_) {
      // A failed fetchClient must be retried on the next attempt.
      _client = null;
      _isInitialized = false;
      rethrow;
    }
  }

  Future<String> getToken(RecaptchaAction action) async {
    if (_client == null) {
      throw Exception(
          "reCAPTCHA Client not initialized. Call initializeClient() first.");
    }

    try {
      // Log the action only; the token must never appear in device logs.
      debugPrint('RECAPTCHA_DEBUG: Executing action ${action.action}');
      final token =
          await _client!.execute(action).timeout(const Duration(seconds: 15));
      return token;
    } on PlatformException {
      rethrow;
    } catch (err) {
      rethrow;
    }
  }
}
