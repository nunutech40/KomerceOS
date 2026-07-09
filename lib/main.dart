import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/app_life_cycle_manager.dart';
import 'package:komtim_partner/core/domain/managers/authentication_manager.dart'
    as auth_mgr;
import 'package:komtim_partner/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart'; // make sure you have this import

import 'common/global/router/app_router.dart';
import 'common/global/router/router_utils.dart';
import 'common/global/widgets/connectivity_wrapper.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/server_error_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized to prevent duplicate app error
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized, continue
      // debugPrint('Firebase already initialized');
    } else {
      // Re-throw other errors
      rethrow;
    }
  }

  await di.initDependencies();
  await di.locator<auth_mgr.AuthenticationManager>().checkLoginStatus();

  // Initialize date locale
  await initializeDateFormatting('id_ID', null);

  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      // debugPrint("FCM Token: $token");
    } else {
      // debugPrint("Failed to retrieve FCM Token");
    }
  } catch (e) {
    // debugPrint("Error retrieving FCM Token: $e");
    // debugPrint(stacktrace.toString());
  }

  // Initialize deep link listener
  await DeepLinkService.instance.init();

  runApp(const MyApp());
}

void setupMethodChannel() {
  const platform = MethodChannel('notification_navigation');
  platform.setMethodCallHandler((call) async {
    // debugPrint(
    //     "MethodChannel invoked: ${call.method}, arguments: ${call.arguments}");
    return _handleMethodCall(call);
  });
}

Future<dynamic> _handleMethodCall(MethodCall call) async {
  switch (call.method) {
    case 'navigate':
      var screen = call.arguments['screen'];
      var invoiceCode = call.arguments['invoiceCode'];
      if (screen.isNotEmpty) {
        AppRouter.router.pushNamed(
          PAGES.invoiceReportSummary.screenName,
          queryParameters: {'invoiceCode': invoiceCode},
        );
      }
      break;
    default:
      throw MissingPluginException('notImplemented');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLifeCycleManager(
      child: FutureBuilder(
        future: di.locator.allReady(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
                home:
                    Scaffold(body: Center(child: CircularProgressIndicator())));
          } else if (snapshot.hasError) {
            return const MaterialApp(
                home: Scaffold(body: Center(child: Text('Error occurred'))));
          } else {
            // Retrieve the AuthenticationManager from DI
            final authManager = di.locator<auth_mgr.AuthenticationManager>();

            // Set navigatorKey ke ServerErrorService agar bisa dipakai oleh interceptor
            ServerErrorService().setNavigatorKey(AppRouter.navigatorKey);

            return ChangeNotifierProvider<auth_mgr.AuthenticationManager>.value(
              value: authManager,
              child: ConnectivityWrapper(
                navigatorKey: AppRouter.navigatorKey,
                child: UpgradeAlert(
                  child: MaterialApp.router(
                    title: 'Komtim Partner',
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      scaffoldBackgroundColor: Colors.white,
                      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
                      useMaterial3: true,
                      bottomSheetTheme: const BottomSheetThemeData(
                          backgroundColor: Colors.white),
                      appBarTheme: const AppBarTheme(
                        backgroundColor: Colors.white,
                      ),
                    ),
                    routeInformationProvider:
                        AppRouter.router.routeInformationProvider,
                    routeInformationParser:
                        AppRouter.router.routeInformationParser,
                    routerDelegate: AppRouter.router.routerDelegate,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
