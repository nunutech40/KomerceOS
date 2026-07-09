import 'package:flutter/services.dart';
import 'package:komtim_partner/config/app_recaptcha_config.dart';
import 'dart:io' show Platform;
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';

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

    try {
      _client = await Recaptcha.fetchClient(siteKey);
      _isInitialized = true;
    } on PlatformException catch (err) {
      _isInitialized = true;
      rethrow; 
    } catch (err) {
      _isInitialized = true;
      rethrow;
    }
  }

  Future<String> getToken(RecaptchaAction action) async {
    if (_client == null) {
      throw Exception("reCAPTCHA Client not initialized. Call initializeClient() first.");
    }
    
    try {
      final token = await _client!.execute(action);
      return token;
    } on PlatformException catch (err) {
      rethrow;
    } catch (err) {
      rethrow;
    }
  }
}
