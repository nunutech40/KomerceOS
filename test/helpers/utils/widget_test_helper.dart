import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper khusus untuk widget testing dengan assertion yang lebih readable
class WidgetTestHelper {
  /// Find widget by key
  static Finder findByKey(String key) => find.byKey(Key(key));

  /// Find widget by type
  static Finder findByType<T>() => find.byType(T);

  /// Find widget by text
  static Finder findByText(String text) => find.text(text);

  /// Find widget by icon
  static Finder findByIcon(IconData icon) => find.byIcon(icon);

  /// Expect widget exists (findsOneWidget)
  static void expectExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Expect widget exists multiple times
  static void expectExistsMultiple(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  /// Expect widget not exists
  static void expectNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// Expect text contains
  static void expectTextContains(String text) {
    expect(find.textContaining(text), findsOneWidget);
  }

  /// Tap button by text
  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();
  }

  /// Tap button by key
  static Future<void> tapButtonByKey(WidgetTester tester, String key) async {
    await tester.tap(findByKey(key));
    await tester.pumpAndSettle();
  }

  /// Tap button by type
  static Future<void> tapButtonByType<T>(WidgetTester tester) async {
    await tester.tap(findByType<T>());
    await tester.pumpAndSettle();
  }

  /// Enter text into field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Enter text by key
  static Future<void> enterTextByKey(
    WidgetTester tester,
    String key,
    String text,
  ) async {
    await tester.enterText(findByKey(key), text);
    await tester.pumpAndSettle();
  }

  /// Verify loading indicator exists
  static void expectLoadingExists() {
    expectExists(find.byType(CircularProgressIndicator));
  }

  /// Verify loading indicator not exists
  static void expectLoadingNotExists() {
    expectNotExists(find.byType(CircularProgressIndicator));
  }

  /// Verify error message exists
  static void expectErrorMessageExists(String message) {
    expectExists(find.text(message));
  }

  /// Scroll to bottom of list
  static Future<void> scrollToBottom(
    WidgetTester tester,
    Finder scrollable,
  ) async {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  /// Scroll to top of list
  static Future<void> scrollToTop(
    WidgetTester tester,
    Finder scrollable,
  ) async {
    await tester.drag(scrollable, const Offset(0, 500));
    await tester.pumpAndSettle();
  }

  /// Pull to refresh gesture
  static Future<void> pullToRefresh(
    WidgetTester tester,
    Finder scrollable,
  ) async {
    await tester.drag(scrollable, const Offset(0, 300));
    await tester.pumpAndSettle();
  }

  /// Wait for a specific duration
  static Future<void> wait(
    WidgetTester tester,
    Duration duration,
  ) async {
    await tester.pump(duration);
  }

  /// Pump frames for animation
  static Future<void> pumpFrames(
    WidgetTester tester,
    int frames,
  ) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump();
    }
  }

  /// Verify widget has specific property
  static void expectWidgetProperty<T extends Widget>(
    WidgetTester tester,
    Finder finder,
    bool Function(T) predicate,
  ) {
    final widget = tester.widget<T>(finder);
    expect(predicate(widget), isTrue);
  }

  /// Get widget of type
  static T getWidget<T extends Widget>(WidgetTester tester, Finder finder) {
    return tester.widget<T>(finder);
  }

  /// Get widget state
  static T getState<T extends State>(WidgetTester tester, Finder finder) {
    return tester.state<T>(finder);
  }

  /// Verify snackbar exists
  static void expectSnackBarExists(String message) {
    expectExists(find.text(message));
    expectExists(find.byType(SnackBar));
  }

  /// Verify dialog exists
  static void expectDialogExists() {
    expectExists(find.byType(Dialog));
  }

  /// Close dialog
  static Future<void> closeDialog(WidgetTester tester) async {
    await tester.tapAt(const Offset(10, 10)); // Tap outside dialog
    await tester.pumpAndSettle();
  }
}

// Provide global access to WidgetTester in helper
WidgetTester? _globalTester;

void setGlobalTester(WidgetTester tester) {
  _globalTester = tester;
}

WidgetTester get tester {
  if (_globalTester == null) {
    throw Exception('Global tester not set. Call setGlobalTester first.');
  }
  return _globalTester!;
}
