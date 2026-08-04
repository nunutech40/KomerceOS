import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/router/go_router_refresh_stream.dart';
import 'package:komtim_partner/core/domain/entities/auth_state.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/core/domain/usecases/reset_password_use_case.dart';
import 'package:komtim_partner/features/pin/view/pin_page.dart';
import 'package:komtim_partner/features/pin/view/verification_email_page.dart';
import 'package:komtim_partner/features/profile/view/profile_info_update_page.dart';
import 'package:komtim_partner/features/ratetalent/view/evaluation_kompoint_page.dart';
import 'package:komtim_partner/features/ratetalent/view/rate_talent_check_page.dart';
import 'package:komtim_partner/features/ratetalent/view/rate_talent_notif_page.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/email_check_page.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/forgot_password.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/login_page.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/new_forgot_password.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/otp_page.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/success_new_password.dart';
import 'package:komtim_partner/features/superapp/features/home/view/main_page.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/view/attendance_pages.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/view/feed_detail_pages.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/view/feed_pages.dart';
import 'package:komtim_partner/features/superapp/features/team/home/bloc/home_team_cubit.dart';
import 'package:komtim_partner/features/superapp/features/team/home/view/home_page_team.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/view/invoice_list_page.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/view/invoice_report_summary_page.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/view/payment_method_page.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/view/success_payment_kompay_page.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/view/detail_report_performance_month_pages.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/view/report_performance_pages.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/view/detail_shopping_page.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/view/shopping_list_page.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/superapp/splash_screen_page.dart';
import 'package:komtim_partner/features/unhire/view/dialog_unhire_finish.dart';
import 'package:komtim_partner/features/unhire/view/reason_unhire_page.dart';
import 'package:komtim_partner/features/unhire/view/unhire_page.dart';
import 'package:komtim_partner/features/update/view/force_update_page.dart';

import '../pages/not_found_page.dart';
import 'router_utils.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final AuthBloc _authBloc = di.locator<AuthBloc>();

  /// Route yang hanya pantas dibuka saat user belum login.
  /// Jika user sudah authenticated dan membuka route ini, router akan
  /// mengembalikan user ke halaman utama.
  static bool _isGuestRoute(String location) {
    return location == PAGES.emailCheck.screenPath ||
        location == PAGES.login.screenPath ||
        location == PAGES.forgotPasswrod.screenPath ||
        location == PAGES.authOtp.screenPath ||
        location == PAGES.newForgotPassword.screenPath ||
        location == PAGES.successNewPassword.screenPath;
  }

  /// Route yang boleh dibuka tanpa session.
  /// Semua route lain dianggap protected secara default, termasuk
  /// change password, PIN, payment, profile, dan fitur utama aplikasi.
  static bool _isPublicRoute(String location) {
    return location == PAGES.splash.screenPath ||
        location == PAGES.forceUpdatePage.screenPath ||
        _isGuestRoute(location);
  }

  static bool _isStartupRoute(String location) {
    return location == PAGES.splash.screenPath ||
        location == PAGES.forceUpdatePage.screenPath;
  }

  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    initialLocation: PAGES.splash.screenPath,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: (context, state) {
      final authStatus = _authBloc.state.status;
      final location = state.matchedLocation;

      if (authStatus == AuthStatus.initial ||
          authStatus == AuthStatus.checking) {
        return _isStartupRoute(location) ? null : PAGES.splash.screenPath;
      }

      if (authStatus == AuthStatus.unauthenticated &&
          !_isPublicRoute(location)) {
        return PAGES.login.screenPath;
      }

      if (authStatus == AuthStatus.authenticated && _isGuestRoute(location)) {
        return PAGES.main.screenPath;
      }

      return null;
    },
    observers: [ChuckerFlutter.navigatorObserver],
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.splash.screenPath,
        name: PAGES.splash.screenName,
        builder: (context, state) => const SplashCreenPage(),
      ),

      // ── Main (Home Superapp) ─────────────────────────────────────────────────
      GoRoute(
        path: PAGES.main.screenPath,
        name: PAGES.main.screenName,
        builder: (context, state) => const MainPageSuperApp(),
      ),

      // ── Team Home ────────────────────────────────────────────────────────────
      // Satu-satunya route yang butuh BlocProvider tambahan karena HomeTeamCubit
      // tidak ada di root MultiBlocProvider di main.dart.
      GoRoute(
        path: PAGES.team.screenPath,
        name: PAGES.team.screenName,
        builder: (context, state) {
          // Ambil BLoC yang sudah ada di root tree — jangan buat instance baru!
          final invoiceBloc = context.read<InvoiceListBloc>();
          final shoppingBloc = context.read<ShoppingBloc>();
          final feedBloc = context.read<FeedBloc>();
          return BlocProvider(
            create: (_) => HomeTeamCubit(
              invoiceListBloc: invoiceBloc,
              shoppingBloc: shoppingBloc,
              feedBloc: feedBloc,
            ),
            child: const HomePageTeam(),
          );
        },
      ),

      // ── Authentication ───────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.emailCheck.screenPath,
        name: PAGES.emailCheck.screenName,
        builder: (context, state) => const EmailCheckPage(),
      ),
      GoRoute(
        path: PAGES.login.screenPath,
        name: PAGES.login.screenName,
        builder: (context, state) {
          final email = state.extra as String?;
          return LoginPage(email: email ?? '');
        },
      ),
      GoRoute(
        path: PAGES.forgotPasswrod.screenPath,
        name: PAGES.forgotPasswrod.screenName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: PAGES.newForgotPassword.screenPath,
        name: PAGES.newForgotPassword.screenName,
        builder: (context, state) {
          final code = state.queryParameters['code'];
          return NewForgotPasswordPage(
            code: code,
            resetPasswordUseCase: di.locator<ResetPasswordUseCase>(),
          );
        },
      ),
      GoRoute(
        path: PAGES.successNewPassword.screenPath,
        name: PAGES.successNewPassword.screenName,
        builder: (context, state) => const SuccessNewPasswordPage(),
      ),
      GoRoute(
        path: PAGES.authOtp.screenPath,
        name: PAGES.authOtp.screenName,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpPage(email: email);
        },
      ),

      // ── Profile ──────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.profileInfo.screenPath,
        name: PAGES.profileInfo.screenName,
        builder: (context, state) => const ProfileInfoUpdatePage(),
      ),

      // ── Invoice ──────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.invoiceList.screenPath,
        name: PAGES.invoiceList.screenName,
        builder: (context, state) {
          final statusAccount = state.queryParameters['statusAccount'] ?? '';
          return InvoiceListPage(statusAccount: statusAccount);
        },
      ),
      GoRoute(
        path: PAGES.invoiceReportSummary.screenPath,
        name: PAGES.invoiceReportSummary.screenName,
        builder: (context, state) {
          final invoiceId = state.queryParameters['invoiceCode'] ?? '';
          final statusAccount = state.queryParameters['statusAccount'] ?? '';
          final from = state.queryParameters['from'] ?? '';
          return InvoiceReportSummaryPage(
            invoiceId: invoiceId,
            statusAccount: statusAccount,
            xenditUrl: '',
            from: from,
          );
        },
      ),

      // ── Rate Talent ──────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.rateTalentNotifPage.screenPath,
        name: PAGES.rateTalentNotifPage.screenName,
        builder: (context, state) {
          final xenditUrl = state.queryParameters['xenditUrl'] ?? '';
          final invoiceID =
              int.tryParse(state.queryParameters['invoiceId'] ?? '0') ?? 0;
          final invoiceCode = state.queryParameters['invoiceCode'] ?? '';
          return RateTalentNotifPage(
            xenditUrl: xenditUrl,
            invoiceId: invoiceID,
            invoiceCode: invoiceCode,
          );
        },
      ),
      GoRoute(
        path: PAGES.rateTalentCheckPage.screenPath,
        name: PAGES.rateTalentCheckPage.screenName,
        builder: (context, state) {
          final xenditUrl = state.queryParameters['xenditUrl'] ?? '';
          final invoiceID =
              int.tryParse(state.queryParameters['invoiceId'] ?? '0') ?? 0;
          final invoiceCode = state.queryParameters['invoiceCode'] ?? '';
          return RateTalentCheckPage(
            xenditUrl: xenditUrl,
            invoiceId: invoiceID,
            invoiceCode: invoiceCode,
          );
        },
      ),
      GoRoute(
        path: PAGES.evaluationKompointPage.screenPath,
        name: PAGES.evaluationKompointPage.screenName,
        builder: (context, state) {
          String xenditUrl = '';
          String invoiceCode = '';
          int invoiceID = 0;
          int komPoint = 0;
          List<TalentsDataModel> submitTalents = [];
          List<TalentLeaderModel> submitLeaders = [];

          final extra = state.extra;
          if (extra != null && extra is Map) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(extra);

            if (map['xenditUrl'] != null) {
              xenditUrl = map['xenditUrl'].toString();
            }
            if (map['invoiceCode'] != null) {
              invoiceCode = map['invoiceCode'].toString();
            }

            final inv = map['invoiceId'];
            if (inv is int) {
              invoiceID = inv;
            } else if (inv is String) {
              invoiceID = int.tryParse(inv) ?? 0;
            }

            final kp = map['komPoint'];
            if (kp is int) {
              komPoint = kp;
            } else if (kp is String) {
              komPoint = int.tryParse(kp) ?? 0;
            }

            final rawTalents = map['submitTalents'];
            if (rawTalents is List<TalentsDataModel>) {
              submitTalents = rawTalents;
            } else if (rawTalents is List) {
              submitTalents = [];
            }

            final rawLeaders = map['submitLeaders'];
            if (rawLeaders is List<TalentLeaderModel>) {
              submitLeaders = rawLeaders;
            } else if (rawLeaders is List) {
              submitLeaders = [];
            }
          }
          return EvaluationKompointPage(
            xenditUrl: xenditUrl,
            invoiceId: invoiceID,
            invoiceCode: invoiceCode,
            komPoint: komPoint,
            submitTalents: submitTalents,
            submitLeaders: submitLeaders,
          );
        },
      ),

      // ── PIN ──────────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.pinPage.screenPath,
        name: PAGES.pinPage.screenName,
        builder: (context, state) {
          Map<String, dynamic> extra = {};
          if (state.extra != null && state.extra is Map<String, dynamic>) {
            extra = state.extra as Map<String, dynamic>;
          }

          final String? pinTypeStr =
              extra['pinType'] ?? state.queryParameters['pinType'];
          final PinPageType pinType =
              pinTypeStr?.toPinPageType() ?? PinPageType.setPin;
          final String? firstPin =
              extra['firstPin'] ?? state.queryParameters['firstPin'];
          final String? doJobFor =
              extra['doJobFor'] ?? state.queryParameters['doJobFor'];
          final String? invoiceId =
              extra['invoiceId'] ?? state.queryParameters['invoiceId'];
          final String? statusA =
              extra['statusA'] ?? state.queryParameters['statusA'];

          return PinPage(
            pinType: pinType,
            firstPin: firstPin,
            doJobfor: doJobFor,
            invoiceId: invoiceId,
            statusA: statusA,
          );
        },
      ),
      GoRoute(
        path: PAGES.pinOtpVerification.screenPath,
        name: PAGES.pinOtpVerification.screenName,
        builder: (context, state) {
          final String? email = state.queryParameters['email'];
          final String? time = state.queryParameters['time'];
          return VerificationEmailPage(email: email, time: time);
        },
      ),

      // ── Unhire ───────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.unhirePage.screenPath,
        name: PAGES.unhirePage.screenName,
        builder: (context, state) => const UnhirePage(),
      ),
      GoRoute(
        path: PAGES.reasonUnhirePage.screenPath,
        name: PAGES.reasonUnhirePage.screenName,
        builder: (context, state) {
          final count =
              double.tryParse(state.queryParameters['count'] ?? '0') ?? 0;
          final index =
              int.tryParse(state.queryParameters['index'] ?? '0') ?? 0;
          final allCount =
              int.tryParse(state.queryParameters['allCount'] ?? '0') ?? 0;
          return UnhireReasonPage(count: count, index: index, allCount: allCount);
        },
      ),
      GoRoute(
        path: PAGES.dialogUnhireFinish.screenPath,
        name: PAGES.dialogUnhireFinish.screenName,
        builder: (context, state) => const DialogUnhireFinish(),
      ),

      // ── Shopping ─────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.shoppingListPage.screenPath,
        name: PAGES.shoppingListPage.screenName,
        builder: (context, state) => const ShoppingListPage(),
      ),
      GoRoute(
        path: PAGES.detailShoppingPage.screenPath,
        name: PAGES.detailShoppingPage.screenName,
        builder: (context, state) {
          final id = int.tryParse(state.queryParameters['id'] ?? '0') ?? 0;
          return DetailShoppingPage(id: id);
        },
      ),

      // ── Attendance ───────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.attendance.screenPath,
        name: PAGES.attendance.screenName,
        builder: (context, state) => const AttendancePages(),
      ),

      // ── Feed ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.feed.screenPath,
        name: PAGES.feed.screenName,
        builder: (context, state) => const FeedPages(),
      ),
      GoRoute(
        path: PAGES.feeddetail.screenPath,
        name: PAGES.feeddetail.screenName,
        builder: (context, state) {
          final id = int.tryParse(state.extra as String);
          return FeedDetailPages(id: id ?? 0);
        },
      ),

      // ── Payment ──────────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.paymentmethod.screenPath,
        name: PAGES.paymentmethod.screenName,
        builder: (context, state) {
          final String invoiceId = state.queryParameters['id'] ?? '';
          final String xenditPaymentUrl =
              state.queryParameters['xenditUrl'] ?? '';
          return PaymentMethodPage(id: invoiceId, xenditUrl: xenditPaymentUrl);
        },
      ),
      GoRoute(
        path: PAGES.successPayment.screenPath,
        name: PAGES.successPayment.screenName,
        builder: (context, state) {
          final String? invoiceId = state.queryParameters['invoiceId'];
          final String? status = state.queryParameters['status'];
          return SuccessPaymentKompayPage(invoiceId: invoiceId, status: status);
        },
      ),

      // ── Performance ──────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.reportperformance.screenPath,
        name: PAGES.reportperformance.screenName,
        builder: (context, state) => const ReportPerformancePages(),
      ),
      GoRoute(
        path: PAGES.reportdetailperformance.screenPath,
        name: PAGES.reportdetailperformance.screenName,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DetailReportPerformanceMonthPages(
            detailModel: extra?['detailModel'] as List<DetailModel>? ?? [],
            productName: extra?['productName'] ?? ' - ',
          );
        },
      ),

      // ── Force Update ─────────────────────────────────────────────────────────
      GoRoute(
        path: PAGES.forceUpdatePage.screenPath,
        name: PAGES.forceUpdatePage.screenName,
        builder: (context, state) => const ForceUpdatePage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );

  static GoRouter get router => _router;

  /// Expose navigator key untuk keperluan global navigation (misal: ConnectivityWrapper)
  static GlobalKey<NavigatorState> get navigatorKey => _rootNavigatorKey;
}
