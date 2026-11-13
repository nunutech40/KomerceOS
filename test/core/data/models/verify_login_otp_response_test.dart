import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/verify_login_otp_response.dart';
import 'package:komtim_partner/core/domain/entities/verify_login_otp_model.dart';

// =============================================================================
// PANDUAN: Data Models / Response — Defensive Parsing & Serialization
// =============================================================================
// 1. Entity map/check    : toEntity() menghasilkan VerifyLoginOtpModel
// 2. Happy Path fromJson : JSON normal -> VerifyLoginOtpResponse utuh
// 3. Edge Path fromJson  : tipe kotor / missing field / non-Map -> null-safe
// 4. Happy Path toJson   : Model -> Map JSON ekuivalen
// =============================================================================

void main() {
  const tResponse = VerifyLoginOtpResponse(
    jwtToken: 'jwt-token-xyz',
    attemptLeft: 2,
  );

  group('toEntity', () {
    test('harus memetakan semua field ke VerifyLoginOtpModel', () {
      final result = tResponse.toEntity();

      expect(result, isA<VerifyLoginOtpModel>());
      expect(result.jwtToken, 'jwt-token-xyz');
      expect(result.attemptLeft, 2);
    });
  });

  group('fromJson', () {
    test('harus mem-parsing JSON normal secara utuh', () {
      final result = VerifyLoginOtpResponse.fromJson(const <String, dynamic>{
        'jwt_token': 'jwt-token-xyz',
        'attempt_left': 2,
      });

      expect(result, tResponse);
    });

    test('defensive parsing: tipe kotor String/double untuk attempt_left', () {
      final result = VerifyLoginOtpResponse.fromJson(const <String, dynamic>{
        'jwt_token': 123456,
        'attempt_left': '2',
      });
      expect(result.jwtToken, '123456');
      expect(result.attemptLeft, 2);

      final doubleResult =
          VerifyLoginOtpResponse.fromJson(const <String, dynamic>{
        'attempt_left': 1.0,
      });
      expect(doubleResult.attemptLeft, 1);
    });

    test('defensive parsing: missing fields atau non-Map/null aman tanpa crash',
        () {
      final emptyResult =
          VerifyLoginOtpResponse.fromJson(const <String, dynamic>{});
      expect(emptyResult.jwtToken, isNull);
      expect(emptyResult.attemptLeft, isNull);

      final invalidIntResult =
          VerifyLoginOtpResponse.fromJson(const <String, dynamic>{
        'attempt_left': 'abc',
      });
      expect(invalidIntResult.attemptLeft, isNull);

      final nullResult = VerifyLoginOtpResponse.fromJson(null);
      expect(nullResult.jwtToken, isNull);
      expect(nullResult.attemptLeft, isNull);
    });
  });

  group('toJson', () {
    test('harus mengembalikan Map JSON ekuivalen', () {
      expect(tResponse.toJson(), {
        'jwt_token': 'jwt-token-xyz',
        'attempt_left': 2,
      });
    });
  });
}

