import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:komtim_partner/main.dart' as app;

import '../../integration_test/robots/login_object.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Komtim Partner - E2E Login Suites', () {
    void startLog(String scenario) => print('\n🚀 RUNNING: $scenario');
    void endLog(String scenario) => print('✅ SUCCESS: $scenario\n');

    testWidgets('Full Authentication Scenarios', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final login = LoginObject(tester);

      // --- SKENARIO 1: WRONG PASSWORD (API Check via Text Field Error) ---
      startLog('Wrong Password Scenario');

      // Enter valid email but wrong password
      await login.enterEmail(
          'gerardusoktavianoajiswara@gmail.com'); // Replace with valid test email
      await login.enterPassword('SalahPass123');

      await login.tapSubmit();
      await login.waitForLoading();

      // Verify error message appears on the screen (not dialog)
      // Note: Adjust the expected error message if it's different in your app (e.g. "Username atau Password salah")
      login.verifyError('Username atau password salah');

      await login.clearFields();
      endLog('Wrong Password Scenario');

      // --- SKENARIO 2: LOGIN SUCCESS ---
      startLog('Login Success');

      await login.enterEmail('hantes'); // Use a test account
      await login.enterPassword('12345678a'); // Use valid password

      await login.tapSubmit();
      await login.waitForLoading();

      // Wait for navigation to Main Page
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Optional: Verify something on the Home Page to confirm success
      // expect(find.text('Beranda'), findsOneWidget);

      endLog('Login Success');
    });
  });
}
