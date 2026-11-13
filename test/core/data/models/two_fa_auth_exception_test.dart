import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/two_fa_auth_exception.dart';
import 'package:komtim_partner/core/domain/entities/two_fa_failure.dart';

void main() {
  group('tryParsePartnerLoginException', () {
    test('return null untuk non-Map atau null responseData', () {
      expect(tryParsePartnerLoginException(500, null), isNull);
      expect(tryParsePartnerLoginException(500, 'error'), isNull);
    });

    test('return null untuk ERR_ROLE_TEAM_INTERNAL_BLOCKED (flat & meta)', () {
      expect(
        tryParsePartnerLoginException(403, {
          'status': false,
          'error_code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
          'message': 'Blocked',
        }),
        isNull,
      );

      expect(
        tryParsePartnerLoginException(403, {
          'meta': {
            'code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
            'message': 'Blocked',
          },
        }),
        isNull,
      );
    });

    test('return null untuk error non-partner agar fallback ServerFailure', () {
      for (final msg in [
        'user is non partner',
        'User is not partner',
        'non partner',
        'non-partner',
      ]) {
        expect(
          tryParsePartnerLoginException(403, {
            'meta': {'code': 403, 'message': msg},
          }),
          isNull,
        );
      }
    });

    test('klasifikasi userNotFound untuk status/meta 500 user not found', () {
      final ex = tryParsePartnerLoginException(500, {
        'meta': {'code': 500, 'message': ' User Not Found '},
      });

      expect(ex, isNotNull);
      expect(ex!.errorType, PartnerLoginErrorType.userNotFound);
      expect(ex.toFailure(), const PartnerLoginFailure(
        'User Not Found',
        errorType: PartnerLoginErrorType.userNotFound,
      ));
    });

    test('klasifikasi otpLocked24Hours saat lock=1 dan lock_source=otp (termasuk string)', () {
      final ex = tryParsePartnerLoginException(400, {
        'meta': {'code': 400, 'message': 'Locked OTP'},
        'data': {'lock': '1', 'lock_source': 'OTP'},
      });

      expect(ex, isNotNull);
      expect(ex!.errorType, PartnerLoginErrorType.otpLocked24Hours);
      expect(ex.lock, 1);
      expect(ex.lockSource, 'OTP');
    });

    test('klasifikasi passwordLocked24Hours dari lock=1 atau pesan lock', () {
      final exByLock = tryParsePartnerLoginException(400, {
        'meta': {'code': 400, 'message': ''},
        'data': {'lock': 1, 'login_attempt': '5'},
      });
      expect(exByLock, isNotNull);
      expect(exByLock!.errorType, PartnerLoginErrorType.passwordLocked24Hours);
      expect(exByLock.loginAttempt, 5);
      expect(exByLock.message, 'Please wait 24 hours to login!');

      final exByText = tryParsePartnerLoginException(400, {
        'meta': {'code': 400, 'message': 'Akun terkunci sementara'},
      });
      expect(exByText!.errorType, PartnerLoginErrorType.passwordLocked24Hours);
    });

    test('klasifikasi incorrectPassword dan parsing login_attempt', () {
      final ex = tryParsePartnerLoginException(400, {
        'meta': {'code': 400, 'message': 'Incorrect Password'},
        'data': {'login_attempt': 2, 'lock': 0},
      });

      expect(ex, isNotNull);
      expect(ex!.errorType, PartnerLoginErrorType.incorrectPassword);
      expect(ex.loginAttempt, 2);
      expect(ex.lock, 0);
    });
  });

  group('tryParseVerifyOtpException', () {
    test('return null untuk non-Map atau status selain 422', () {
      expect(tryParseVerifyOtpException(422, null), isNull);
      expect(
        tryParseVerifyOtpException(400, {
          'meta': {'code': 400, 'message': 'OTP not valid'},
        }),
        isNull,
      );
    });

    test('klasifikasi expiredToken, otpInvalid, dan otpInvalidLocked pada 422', () {
      final expired = tryParseVerifyOtpException(422, {
        'meta': {'code': 422, 'message': 'Expired token'},
      });
      expect(expired!.errorType, VerifyOtpErrorType.expiredToken);

      final invalid = tryParseVerifyOtpException(422, {
        'meta': {'code': 422, 'message': 'OTP not valid'},
        'data': {'attempt_left': '2', 'lock': '0'},
      });
      expect(invalid!.errorType, VerifyOtpErrorType.otpInvalid);
      expect(invalid.attemptLeft, 2);
      expect(invalid.lock, 0);

      final locked = tryParseVerifyOtpException(422, {
        'meta': {'code': 422, 'message': 'OTP not valid'},
        'data': {'attempt_left': 0, 'lock': 1},
      });
      expect(locked!.errorType, VerifyOtpErrorType.otpInvalidLocked);
      expect(locked.attemptLeft, 0);
      expect(locked.lock, 1);
    });
  });

  group('Failure equality with null vs absent fields', () {
    test('PartnerLoginFailure dan VerifyOtpFailure membedakan field secara presisi', () {
      const a = PartnerLoginFailure(
        'Incorrect Password',
        errorType: PartnerLoginErrorType.incorrectPassword,
        loginAttempt: null,
        lock: 0,
      );
      const b = PartnerLoginFailure(
        'Incorrect Password',
        errorType: PartnerLoginErrorType.incorrectPassword,
        loginAttempt: 1,
        lock: 0,
      );
      const c = VerifyOtpFailure(
        'OTP not valid',
        errorType: VerifyOtpErrorType.otpInvalid,
        attemptLeft: null,
        lock: 0,
      );
      const d = VerifyOtpFailure(
        'OTP not valid',
        errorType: VerifyOtpErrorType.otpInvalid,
        attemptLeft: 0,
        lock: 0,
      );

      expect(a == b, isFalse);
      expect(c == d, isFalse);
    });
  });
}

