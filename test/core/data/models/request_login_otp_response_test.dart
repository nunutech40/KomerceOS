import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/request_login_otp_response.dart';
import 'package:komtim_partner/core/domain/entities/request_login_otp_model.dart';

// =============================================================================
// PANDUAN: Data Models / Response — Defensive Parsing & Serialization
// =============================================================================
// 1. Entity map/check    : toEntity() menghasilkan RequestLoginOtpModel
// 2. Happy Path fromJson : JSON normal -> RequestLoginOtpResponse utuh
// 3. Edge Path fromJson  : tipe kotor / missing field / non-Map -> null-safe
// 4. Happy Path toJson   : Model -> Map JSON ekuivalen
// =============================================================================

void main() {
  const tResponse = RequestLoginOtpResponse(
    token: 'otp-token-456',
    expiredAt: '2026-11-12T12:05:00Z',
    expiresIn: 60,
    email: 'ger***@g***com',
    phone: '*******0034',
    otpLimitExceeded: true,
  );

  group('toEntity', () {
    test('harus memetakan semua field ke RequestLoginOtpModel', () {
      final result = tResponse.toEntity();

      expect(result, isA<RequestLoginOtpModel>());
      expect(result.token, 'otp-token-456');
      expect(result.expiredAt, '2026-11-12T12:05:00Z');
      expect(result.expiresIn, 60);
      expect(result.email, 'ger***@g***com');
      expect(result.phone, '*******0034');
      expect(result.otpLimitExceeded, isTrue);
    });
  });

  group('fromJson', () {
    test('harus mem-parsing JSON normal secara utuh', () {
      final jsonMap = <String, dynamic>{
        'token': 'otp-token-456',
        'expired_at': '2026-11-12T12:05:00Z',
        'expires_in': 60,
        'email': 'ger***@g***com',
        'phone': '*******0034',
        'otp_limit_exceeded': true,
      };

      final result = RequestLoginOtpResponse.fromJson(jsonMap);

      expect(result, tResponse);
    });

    test('defensive parsing: tipe kotor untuk expires_in dan otp_limit_exceeded',
        () {
      final dirtyJson = <String, dynamic>{
        'token': 7788,
        'expired_at': '2026-11-12T12:05:00Z',
        'expires_in': '59',
        'otp_limit_exceeded': 'true',
      };

      final result = RequestLoginOtpResponse.fromJson(dirtyJson);

      expect(result.token, '7788');
      expect(result.expiresIn, 59);
      expect(result.otpLimitExceeded, isTrue);

      final numJson = <String, dynamic>{
        'expires_in': 30.0,
        'otp_limit_exceeded': 0,
      };
      final numResult = RequestLoginOtpResponse.fromJson(numJson);
      expect(numResult.expiresIn, 30);
      expect(numResult.otpLimitExceeded, isFalse);
    });

    test('defensive parsing: missing fields atau non-Map tidak crash', () {
      final emptyResult =
          RequestLoginOtpResponse.fromJson(const <String, dynamic>{});
      expect(emptyResult.token, isNull);
      expect(emptyResult.expiredAt, isNull);
      expect(emptyResult.expiresIn, isNull);
      expect(emptyResult.email, isNull);
      expect(emptyResult.phone, isNull);
      expect(emptyResult.otpLimitExceeded, isFalse);

      final nonMapResult = RequestLoginOtpResponse.fromJson('not-a-map');
      expect(nonMapResult.token, isNull);
      expect(nonMapResult.otpLimitExceeded, isFalse);
    });
  });

  group('toJson', () {
    test('harus mengembalikan Map JSON ekuivalen', () {
      expect(tResponse.toJson(), {
        'token': 'otp-token-456',
        'expired_at': '2026-11-12T12:05:00Z',
        'expires_in': 60,
        'email': 'ger***@g***com',
        'phone': '*******0034',
        'otp_limit_exceeded': true,
      });
    });
  });
}

