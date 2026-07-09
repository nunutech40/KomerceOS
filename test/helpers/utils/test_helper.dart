import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper class untuk mempermudah widget testing
class TestHelper {
  /// Wrap widget dengan MaterialApp untuk testing
  /// 
  /// Usage:
  /// ```dart
  /// await tester.pumpWidget(
  ///   TestHelper.wrapWithMaterialApp(MyWidget()),
  /// );
  /// ```
  static Widget wrapWithMaterialApp(
    Widget child, {
    ThemeData? theme,
    Locale? locale,
    List<NavigatorObserver>? navigatorObservers,
  }) {
    return MaterialApp(
      theme: theme,
      locale: locale,
      navigatorObservers: navigatorObservers ?? [],
      home: Scaffold(body: child),
    );
  }

  /// Wrap widget dengan MaterialApp dan BlocProvider
  /// 
  /// Usage:
  /// ```dart
  /// await tester.pumpWidget(
  ///   TestHelper.wrapWithBlocProvider<MyBloc>(
  ///     bloc: mockBloc,
  ///     child: MyWidget(),
  ///   ),
  /// );
  /// ```
  static Widget wrapWithBlocProvider<B extends StateStreamableSource<Object?>>(
    {
    required B bloc,
    required Widget child,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: BlocProvider<B>.value(
          value: bloc,
          child: child,
        ),
      ),
    );
  }

  /// Wrap widget dengan MaterialApp dan multiple BlocProviders
  /// 
  /// Usage:
  /// ```dart
  /// await tester.pumpWidget(
  ///   TestHelper.wrapWithMultipleBlocProviders(
  ///     providers: [
  ///       BlocProvider<MyBloc>.value(value: mockBloc1),
  ///       BlocProvider<AnotherBloc>.value(value: mockBloc2),
  ///     ],
  ///     child: MyWidget(),
  ///   ),
  /// );
  /// ```
  static Widget wrapWithMultipleBlocProviders({
    required List<BlocProvider> providers,
    required Widget child,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: providers,
          child: child,
        ),
      ),
    );
  }

  /// Helper untuk menunggu animasi selesai
  /// 
  /// Usage:
  /// ```dart
  /// await TestHelper.pumpAndSettleWithTimeout(tester);
  /// ```
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Helper untuk tap dan tunggu animasi
  /// 
  /// Usage:
  /// ```dart
  /// await TestHelper.tapAndSettle(tester, find.byType(MyButton));
  /// ```
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Helper untuk scroll sampai widget terlihat
  /// 
  /// Usage:
  /// ```dart
  /// await TestHelper.scrollUntilVisible(
  ///   tester,
  ///   find.text('My Widget'),
  ///   find.byType(ListView),
  /// );
  /// ```
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder item,
    Finder scrollable, {
    double delta = 100.0,
    int maxScrolls = 50,
  }) async {
    int scrollCount = 0;
    while (scrollCount < maxScrolls) {
      if (tester.any(item)) {
        await tester.ensureVisible(item);
        return;
      }
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pumpAndSettle();
      scrollCount++;
    }
    throw Exception('Widget tidak ditemukan setelah $maxScrolls kali scroll');
  }

  /// Helper untuk enter text dan tunggu
  /// 
  /// Usage:
  /// ```dart
  /// await TestHelper.enterTextAndSettle(
  ///   tester,
  ///   find.byType(TextField),
  ///   'test@example.com',
  /// );
  /// ```
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Verify text ada dalam widget
  /// 
  /// Usage:
  /// ```dart
  /// TestHelper.verifyTextExists('Hello World');
  /// ```
  static void verifyTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify widget type ada
  /// 
  /// Usage:
  /// ```dart
  /// TestHelper.verifyWidgetExists<CircularProgressIndicator>();
  /// ```
  static void verifyWidgetExists<T>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Verify widget tidak ada
  /// 
  /// Usage:
  /// ```dart
  /// TestHelper.verifyWidgetNotExists<ErrorWidget>();
  /// ```
  static void verifyWidgetNotExists<T>() {
    expect(find.byType(T), findsNothing);
  }
}
