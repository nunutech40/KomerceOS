import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/styles.dart';

/// Helper untuk wrap widget dengan MaterialApp dan semua dependencies
/// Gunakan ini sebagai standard way untuk setup widget test
/// 
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   pumpApp(MyWidget()),
/// );
/// ```
Widget pumpApp(
  Widget child, {
  ThemeData? theme,
  List<BlocProvider>? providers,
  List<NavigatorObserver>? navigatorObservers,
}) {
  final app = MaterialApp(
    theme: theme ?? ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    ),
    navigatorObservers: navigatorObservers ?? [],
    home: Scaffold(body: child),
  );

  // Jika ada BLoC providers, wrap dengan MultiBlocProvider
  if (providers != null && providers.isNotEmpty) {
    return MultiBlocProvider(
      providers: providers,
      child: app,
    );
  }

  return app;
}

/// Helper untuk wrap dengan single BLoC provider
/// 
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   pumpAppWithBloc<MyBloc>(
///     bloc: mockBloc,
///     child: MyWidget(),
///   ),
/// );
/// ```
Widget pumpAppWithBloc<B extends StateStreamableSource<Object?>>({
  required B bloc,
  required Widget child,
  ThemeData? theme,
}) {
  return pumpApp(
    child,
    theme: theme,
    providers: [
      BlocProvider<B>.value(value: bloc),
    ],
  );
}
