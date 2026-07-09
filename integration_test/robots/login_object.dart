import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginObject {
  final WidgetTester tester;
  LoginObject(this.tester);

  final emailField = find.byKey(const Key('login_email_input'));
  final passwordField = find.byKey(const Key('login_pass_input'));
  final submitButton = find.byKey(const Key('button_submit'));

  Future<void> clearFields() async {
    await tester.enterText(emailField, '');
    await tester.enterText(passwordField, '');
    await tester.pumpAndSettle();
  }

  Future<void> enterEmail(String email) async {
    await tester.waitUntilVisible(emailField);
    await tester.typeText(emailField, email);
    await tester.pumpAndSettle();
  }

  Future<void> enterPassword(String password) async {
    await tester.waitUntilVisible(passwordField);
    await tester.typeText(passwordField, password);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit() async {
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  Future<void> waitForLoading() async {
    // Wait for any potential loading indicators or API calls
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  void verifySuccess() {
    // Modify this if your success state shows a specific widget or text
    // For now assuming navigating to main page effectively
    // You might want to find a widget specific to the Main Page
  }

  void verifyError(String message) {
    expect(find.text(message), findsAtLeastNWidgets(1));
  }

  // Adapted verify methods for komtim_partner where errors show on the field
  void verifyEmailError(String message) {
    expect(find.text(message), findsAtLeastNWidgets(1));
  }
}

extension WidgetTesterExt on WidgetTester {
  Future<void> waitUntilVisible(Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    bool isVisible = false;
    final timer = Stopwatch()..start();
    while (!isVisible && timer.elapsed < timeout) {
      final elements = finder.evaluate();
      if (elements.isNotEmpty) {
        isVisible = true;
        break;
      }
      await pump(const Duration(milliseconds: 100));
    }
    if (!isVisible) {
      throw Exception('Widget tidak ditemukan: ${finder.description}');
    }
  }

  Future<void> typeText(Finder finder, String text) async {
    await tap(finder);
    await pumpAndSettle();

    await enterText(finder, text);
    await pumpAndSettle();
  }
}
