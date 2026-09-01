import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/app_life_cycle_manager.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/firebase_options.dart';
import 'package:upgrader/upgrader.dart';

import 'common/global/bloc/auth/auth_bloc.dart';
import 'common/global/bloc/auth/auth_event.dart';
import 'common/global/bloc/global_alert/global_alert_bloc.dart';
import 'common/global/bloc/global_alert/global_alert_state.dart';
import 'common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'common/global/router/app_router.dart';
import 'common/global/router/router_utils.dart';
import 'common/global/widgets/connectivity_wrapper.dart';
import 'core/services/deep_link_service.dart';
import 'features/pin/bloc/pin_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/superapp/features/authentication/bloc/check_email_bloc.dart';
import 'features/superapp/features/authentication/bloc/forgot_password_bloc.dart';
import 'features/superapp/features/authentication/bloc/login_bloc.dart';
import 'features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import 'features/superapp/features/notification/bloc/notification_info_bloc.dart';
import 'features/superapp/features/team/attendance/bloc/attendance_bloc.dart';
import 'features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart';
import 'features/superapp/features/team/invoice/bloc/payment_method_bloc.dart';
import 'features/superapp/features/team/performance/bloc/report_performance_bloc.dart';
import 'features/superapp/features/team/ratetalent/bloc/rate_talent_bloc.dart';
import 'features/superapp/features/team/shopping/bloc/shopping_bloc.dart';
import 'features/superapp/features/topup/bloc/check_bill_bloc.dart';
import 'features/superapp/features/topup/bloc/expire_invoice_bloc.dart';
import 'features/superapp/features/topup/bloc/expire_qrcode_bloc.dart';
import 'features/unhire/bloc/talent_list_bloc.dart';
import 'features/unhire/bloc/talent_list_selected_bloc.dart';

bool _isServerErrorShowing = false;

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

  // Dispatch AuthCheckRequested agar AuthBloc memeriksa session yang tersimpan
  // (token di SecureStorage). Router akan reaktif terhadap hasilnya.
  di.locator<AuthBloc>().add(AuthCheckRequested());

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
            return MultiBlocProvider(
              providers: [
                // ── GLOBAL BLOCS ──────────────────────────────────────────
                BlocProvider<AuthBloc>.value(value: di.locator<AuthBloc>()),
                BlocProvider<GlobalAlertBloc>.value(
                    value: di.locator<GlobalAlertBloc>()),
                BlocProvider<SuperappProfileBloc>.value(
                    value: di.locator<SuperappProfileBloc>()),
                // ── AUTHENTICATION ────────────────────────────────────────
                BlocProvider<CheckEmailBloc>(
                    create: (_) => di.locator<CheckEmailBloc>()),
                BlocProvider<LoginBloc>(create: (_) => di.locator<LoginBloc>()),
                BlocProvider<ForgotPasswordBloc>(
                    create: (_) => di.locator<ForgotPasswordBloc>()),
                // ── HOME ──────────────────────────────────────────────────
                BlocProvider<BalanceSummaryBloc>(
                    create: (_) => di.locator<BalanceSummaryBloc>()),
                BlocProvider<RevenuePerformanceBloc>(
                    create: (_) => di.locator<RevenuePerformanceBloc>()),
                BlocProvider<CheckBillBloc>(
                    create: (_) => di.locator<CheckBillBloc>()),
                BlocProvider<NotificationInfoBloc>(
                    create: (_) => di.locator<NotificationInfoBloc>()),
                // ── PROFILE ───────────────────────────────────────────────
                BlocProvider<ProfileBloc>(
                    create: (_) => di.locator<ProfileBloc>()),
                // ── INVOICE ───────────────────────────────────────────────
                BlocProvider<InvoiceListBloc>(
                    create: (_) => di.locator<InvoiceListBloc>()),
                BlocProvider<InvoiceDetailBloc>(
                    create: (_) => di.locator<InvoiceDetailBloc>()),
                BlocProvider<PaymentMethodBloc>(
                    create: (_) => di.locator<PaymentMethodBloc>()),
                // ── RATE TALENT ───────────────────────────────────────────
                BlocProvider<RateTalentBloc>(
                    create: (_) => di.locator<RateTalentBloc>()),
                // ── KOMPAY / TOPUP ────────────────────────────────────────
                BlocProvider<ExpireQrcodeBloc>(
                    create: (_) => di.locator<ExpireQrcodeBloc>()),
                BlocProvider<ExpireInvoiceBloc>(
                    create: (_) => di.locator<ExpireInvoiceBloc>()),
                // ── PIN ───────────────────────────────────────────────────
                BlocProvider<PinBloc>(create: (_) => di.locator<PinBloc>()),
                // ── UNHIRE ────────────────────────────────────────────────
                BlocProvider<TalentListBloc>(
                    create: (_) => di.locator<TalentListBloc>()),
                BlocProvider<TalentListSelectedBloc>(
                    create: (_) => di.locator<TalentListSelectedBloc>()),
                // ── SHOPPING ──────────────────────────────────────────────
                BlocProvider<ShoppingBloc>(
                    create: (_) => di.locator<ShoppingBloc>()),
                // ── ATTENDANCE & FEED ─────────────────────────────────────
                BlocProvider<AttendanceBloc>(
                    create: (_) => di.locator<AttendanceBloc>()),
                BlocProvider<FeedBloc>(create: (_) => di.locator<FeedBloc>()),
                // ── PERFORMANCE ───────────────────────────────────────────
                BlocProvider<ReportPerformanceBloc>(
                    create: (_) => di.locator<ReportPerformanceBloc>()),
              ],
              child: ConnectivityWrapper(
                navigatorKey: AppRouter.navigatorKey,
                child: UpgradeAlert(
                  child: BlocListener<GlobalAlertBloc, GlobalAlertState>(
                    listener: (context, state) {
                      if (state is GlobalAlertShowServerError) {
                        if (_isServerErrorShowing) return;

                        final navContext =
                            AppRouter.navigatorKey.currentContext;
                        if (navContext == null) return;

                        _isServerErrorShowing = true;
                        DsBottomSheet.show(
                          context: navContext,
                          isDismissible: true,
                          title: 'Server Error',
                          description:
                              'Terjadi kendala pada sistem. Silakan\ncoba kembali beberapa saat lagi.',
                          image: SvgPicture.asset(
                            'assets/images/superapp/auth/server_error.svg',
                            width: 160,
                            height: 200,
                          ),
                          secondaryButtonText: 'Kembali',
                          onSecondaryPressed: () {
                            Navigator.pop(navContext);
                          },
                          primaryButtonText: 'Coba Lagi',
                          onPrimaryPressed: () {
                            Navigator.pop(navContext);
                          },
                          onClosePressed: () {
                            Navigator.pop(navContext);
                          },
                        ).whenComplete(() {
                          _isServerErrorShowing = false;
                        });
                      }
                    },
                    child: MaterialApp.router(
                      title: 'Komerce OS',
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
              ),
            );
          }
        },
      ),
    );
  }
}
