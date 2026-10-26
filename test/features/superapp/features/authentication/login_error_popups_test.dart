import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/login_error_popups.dart';

void main() {
  group('LoginErrorPopups role mapping', () {
    test('error code Team Internal memakai jalur akses ditolak khusus', () {
      const message =
          'ERR_ROLE_TEAM_INTERNAL_BLOCKED: Akun Anda tidak memiliki akses untuk masuk ke aplikasi.';

      expect(LoginErrorPopups.isTeamInternalBlocked(message), isTrue);
      expect(LoginErrorPopups.isOtherRoleError(message), isFalse);
    });

    test('pesan backend Team Internal tanpa kode tetap memakai jalur khusus',
        () {
      const message =
          'Akun Anda dengan role Team Internal tidak memiliki akses untuk masuk ke aplikasi Komerce OS demi alasan keamanan.';

      expect(LoginErrorPopups.isTeamInternalBlocked(message), isTrue);
      expect(LoginErrorPopups.isOtherRoleError(message), isFalse);
    });

    test('role lain tetap menggunakan jalur customer support', () {
      expect(LoginErrorPopups.isOtherRoleError('User is non partner'), isTrue);
      expect(
        LoginErrorPopups.isTeamInternalBlocked('User is non partner'),
        isFalse,
      );
    });
  });
}
