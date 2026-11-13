import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/partner_login_response.dart';
import 'package:komtim_partner/core/domain/entities/partner_login_model.dart';

// =============================================================================
// PANDUAN: Data Models / Response — Defensive Parsing & Serialization
// =============================================================================
// 1. Entity map/check    : toEntity() menghasilkan domain Entity yang benar
// 2. Happy Path fromJson : JSON mulus -> Model utuh
// 3. Edge Path fromJson  : API mengirim tipe kotor (String -> Int/Bool, dll)
// 4. Edge Path fromJson  : API mengirim data bolong / non-Map -> null-safe
// 5. Happy Path toJson   : Model -> Map JSON ekuivalen
// =============================================================================

void main() {
  const tPendingOtpResponse = PendingOtpResponse(
    token: 'otp-token-123',
    expiredAt: '2026-11-12T12:00:00Z',
    expiresIn: 60,
    typeToken: 'wa',
  );

  const tPartnerLoginResponse = PartnerLoginResponse(
    token: 'login-token-abc',
    email: 'ger***@g***com',
    phone: '*******0034',
    pendingOtp: tPendingOtpResponse,
    otpLimitExceeded: true,
  );

  group('toEntity', () {
    test(
        'toEntity harus memetakan seluruh field termasuk pendingOtp ke PartnerLoginModel',
        () {
      final result = tPartnerLoginResponse.toEntity();

      expect(result, isA<PartnerLoginModel>());
      expect(result.token, 'login-token-abc');
      expect(result.email, 'ger***@g***com');
      expect(result.phone, '*******0034');
      expect(result.otpLimitExceeded, isTrue);
      expect(result.pendingOtp, isA<PendingOtpModel>());
      expect(result.pendingOtp?.token, 'otp-token-123');
      expect(result.pendingOtp?.expiredAt, '2026-11-12T12:00:00Z');
      expect(result.pendingOtp?.expiresIn, 60);
      expect(result.pendingOtp?.typeToken, 'wa');
    });
  });

  group('fromJson', () {
    test('harus mem-parsing JSON normal menjadi PartnerLoginResponse utuh', () {
      final jsonMap = <String, dynamic>{
        'token': 'login-token-abc',
        'email': 'ger***@g***com',
        'phone': '*******0034',
        'pending_otp': {
          'token': 'otp-token-123',
          'expired_at': '2026-11-12T12:00:00Z',
          'expires_in': 60,
          'type_token': 'wa',
        },
        'otp_limit_exceeded': true,
      };

      final result = PartnerLoginResponse.fromJson(jsonMap);

      expect(result, tPartnerLoginResponse);
    });

    test('defensive parsing: tipe kotor String/num untuk int dan bool tetap aman',
        () {
      final dirtyJson = <String, dynamic>{
        'token': 12345,
        'email': 'ger***@g***com',
        'phone': 62812340034,
        'pending_otp': {
          'token': 999,
          'expired_at': '2026-11-12T12:00:00Z',
          'expires_in': '59',
          'type_token': 'sms',
        },
        'otp_limit_exceeded': '1',
      };

      final result = PartnerLoginResponse.fromJson(dirtyJson);

      expect(result.token, '12345');
      expect(result.phone, '62812340034');
      expect(result.otpLimitExceeded, isTrue);
      expect(result.pendingOtp?.token, '999');
      expect(result.pendingOtp?.expiresIn, 59);
      expect(result.pendingOtp?.typeToken, 'sms');

      final numBoolJson = <String, dynamic>{
        'otp_limit_exceeded': 1,
        'pending_otp': {
          'expires_in': 45.0,
        },
      };
      final numResult = PartnerLoginResponse.fromJson(numBoolJson);
      expect(numResult.otpLimitExceeded, isTrue);
      expect(numResult.pendingOtp?.expiresIn, 45);
    });

    test('defensive parsing: missing fields, pending_otp bukan Map, atau root null/non-Map tidak crash',
        () {
      final missingResult =
          PartnerLoginResponse.fromJson(const <String, dynamic>{
        'token': 'only-login-token',
        'pending_otp': 'invalid-type',
      });

      expect(missingResult.token, 'only-login-token');
      expect(missingResult.email, isNull);
      expect(missingResult.phone, isNull);
      expect(missingResult.pendingOtp, isNull);
      expect(missingResult.otpLimitExceeded, isFalse);

      final nullRoot = PartnerLoginResponse.fromJson(null);
      expect(nullRoot.token, isNull);
      expect(nullRoot.pendingOtp, isNull);
      expect(nullRoot.otpLimitExceeded, isFalse);

      final listRoot = PartnerLoginResponse.fromJson(const ['unexpected']);
      expect(listRoot.token, isNull);
      expect(listRoot.pendingOtp, isNull);
    });
  });

  group('toJson', () {
    test('harus mengembalikan Map JSON ekuivalen beserta nested pending_otp',
        () {
      final result = tPartnerLoginResponse.toJson();

      expect(result, const {
        'token': 'login-token-abc',
        'email': 'ger***@g***com',
        'phone': '*******0034',
        'pending_otp': {
          'token': 'otp-token-123',
          'expired_at': '2026-11-12T12:00:00Z',
          'expires_in': 60,
          'type_token': 'wa',
        },
        'otp_limit_exceeded': true,
      });
    });
  });
}

