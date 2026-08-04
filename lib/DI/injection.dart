import 'package:get_it/get_it.dart';
import 'package:komtim_partner/core/data/datasources/remote/attendance_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/expire_invoice_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/feed_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/invoice_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/kompay_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/kompoin_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/pin_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/report_performance_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/shopping_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/talent_recomendation_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/talent_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/topup_remote_datasource.dart';
import 'package:komtim_partner/core/data/datasources/remote/transaction_history_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/expire_invoice_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/feed_reporsitory_impl.dart';
import 'package:komtim_partner/core/data/repositories/invoice_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/kompay_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/kompoin_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/pin_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/report_performance_impl.dart';
import 'package:komtim_partner/core/data/repositories/shopping_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/talent_recomendation_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/talent_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/topup_repository_impl.dart';
import 'package:komtim_partner/core/data/repositories/transaction_history_repository_impl.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';
import 'package:komtim_partner/core/domain/repositories/expire_invoice_repository.dart';
import 'package:komtim_partner/core/domain/repositories/feed_reporsitory.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';
import 'package:komtim_partner/core/domain/repositories/kompoin_repository.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';
import 'package:komtim_partner/core/domain/repositories/report_performance_repository.dart';
import 'package:komtim_partner/core/domain/repositories/shopping_repository.dart';
import 'package:komtim_partner/core/domain/repositories/talent_recomendation.dart';
import 'package:komtim_partner/core/domain/repositories/talent_repository.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';
import 'package:komtim_partner/core/domain/repositories/transaction_history_repository.dart';
import 'package:komtim_partner/core/domain/repositories/withdrawal_kompay_repository.dart';
import 'package:komtim_partner/core/domain/usecases/cancel_shopping_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/check_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/check_talent_evaluation_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/delete_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/do_payment_kompay_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/download_attendance.dart';
import 'package:komtim_partner/core/domain/usecases/download_invoice_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/expire_invoice_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/forget_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_attendance_absences_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_attendance_fail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_balance_analytics_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_bank_list_withdrawal_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_detail_shopping_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_feed_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_ideal_balance_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_invoice_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_invoices_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_locale_profile_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_notif_read_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_notifications_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_push_notif_count_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_monthly_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_product_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_weekly_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_shopping_list_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_evaluation_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_selected_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_telant_recomendation_usec_ase.dart';
import 'package:komtim_partner/core/domain/usecases/get_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_transaction_history_need_process_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_transaction_history_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/pay_shopping_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/recaptcha_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_talent_selected_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/save_time_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/send_unhire_talents_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/set_rating_talents_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_cancel_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_ceck_transaction_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_detail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_kompoin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/topup_qris_usecase.dart';
import 'package:komtim_partner/core/domain/usecases/topup_usecase.dart';
import 'package:komtim_partner/core/domain/usecases/verify_otp_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/withdraw_kompoin_use_case.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/bloc/attendance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/payment_method_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_bloc.dart';
import 'package:komtim_partner/features/pin/bloc/pin_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_invoice_bloc.dart';
import 'package:komtim_partner/features/unhire/bloc/talent_list_bloc.dart';
import 'package:komtim_partner/features/unhire/bloc/talent_list_selected_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/global/bloc/auth/auth_bloc.dart';
import '../common/global/bloc/global_alert/global_alert_bloc.dart';
import '../common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import '../core/data/apiservice/dio_client.dart';
import '../core/data/apiservice/dio_response_parser.dart';
import '../core/data/apiservice/interceptors/auth_interceptor.dart';
import '../core/data/apiservice/token_provider.dart';
import '../core/data/datasources/preferences/secure_storage_service.dart';
import '../core/data/datasources/preferences/shared_pref.dart';
import '../core/data/datasources/remote/auth_remote_datasource.dart';
import '../core/data/datasources/remote/balance_summary_remote_datasource.dart';
import '../core/data/datasources/remote/check_bill_remote_datasource.dart';
import '../core/data/datasources/remote/check_qrcode_remote_datasource.dart';
import '../core/data/datasources/remote/create_invoice_remote_datasource.dart';
import '../core/data/datasources/remote/create_qrcode_remote_datasource.dart';
import '../core/data/datasources/remote/expire_qrcode_remote_datasource.dart';
import '../core/data/datasources/remote/notification_v2_remote_datasource.dart';
import '../core/data/datasources/remote/profile_remote_datasource.dart';
import '../core/data/datasources/remote/revenue_performance_remote_datasource.dart';
import '../core/data/datasources/remote/superapp_profile_remote_datasource.dart';
import '../core/data/repositories/attendance_repository_imp.dart';
import '../core/data/repositories/auth_repository_impl.dart';
import '../core/data/repositories/balance_summary_repository_impl.dart';
import '../core/data/repositories/check_bill_repository_impl.dart';
import '../core/data/repositories/check_qrcode_repository.dart';
import '../core/data/repositories/create_invoice_repository.dart';
import '../core/data/repositories/create_qrcode_repository.dart';
import '../core/data/repositories/expire_qrcode_repository_impl.dart';
import '../core/data/repositories/notification_v2_repository_impl.dart';
import '../core/data/repositories/profile_repository_impl.dart';
import '../core/data/repositories/revenue_performance_repository_impl.dart';
import '../core/data/repositories/superapp_profile_repository_impl.dart';
import '../core/data/services/firebase_logout_cleanup_service.dart';
import '../core/data/shared/payload.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/balance_summary_repository.dart';
import '../core/domain/repositories/check_bill_repository.dart';
import '../core/domain/repositories/expire_qrcode_repository.dart';
import '../core/domain/repositories/notification_v2_repository.dart';
import '../core/domain/repositories/profile_repository.dart';
import '../core/domain/repositories/revenue_performance_repository.dart';
import '../core/domain/services/logout_cleanup_service.dart';
import '../core/domain/usecases/change_password_use_case.dart';
import '../core/domain/usecases/check_bill_use_case.dart';
import '../core/domain/usecases/check_email_login_use_case.dart';
import '../core/domain/usecases/check_qrcode_use_case.dart';
import '../core/domain/usecases/create_invoice_use_case.dart';
import '../core/domain/usecases/create_qrcode_use_case.dart';
import '../core/domain/usecases/do_login_use_case.dart';
import '../core/domain/usecases/do_logout_use_case.dart';
import '../core/domain/usecases/expire_qrcode_use_case.dart';
import '../core/domain/usecases/get_attendance_use_case.dart';
import '../core/domain/usecases/get_auth_state_use_case.dart';
import '../core/domain/usecases/get_balance_summary_use_case.dart';
import '../core/domain/usecases/get_notification_info_use_case.dart';
import '../core/domain/usecases/get_notification_v2_list_use_case.dart';
import '../core/domain/usecases/get_profile_use_case.dart';
import '../core/domain/usecases/get_revenue_performance_use_case.dart';
import '../core/domain/usecases/read_notification_v2_use_case.dart';
import '../core/domain/usecases/resend_verification_use_case.dart';
import '../core/domain/usecases/reset_password_use_case.dart';
import '../core/domain/usecases/send_forgot_password_use_case.dart';
import '../core/domain/usecases/update_selected_talent_use_case.dart';
import '../features/profile/bloc/profile_bloc.dart';
import '../features/ratetalent/bloc/rate_talent_bloc.dart';
import '../features/superapp/features/authentication/bloc/check_email_bloc.dart';
import '../features/superapp/features/authentication/bloc/forgot_password_bloc.dart';
import '../features/superapp/features/authentication/bloc/login_bloc.dart'
    as superapp_auth;
import '../features/superapp/features/authentication/bloc/verification_bloc.dart';
import '../features/superapp/features/home/bloc/balance_summary_bloc.dart';
import '../features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import '../features/superapp/features/myapp/bloc/aplikasiku_bloc.dart';
import '../features/superapp/features/myapp/data/datasource/aplikasiku_remote_datasource.dart';
import '../features/superapp/features/myapp/data/repositories/aplikasiku_repository_impl.dart';
import '../features/superapp/features/myapp/domain/repositories/aplikasiku_repository.dart';
import '../features/superapp/features/myapp/domain/usecases/get_aplikasiku_list_usecase.dart';
import '../features/superapp/features/notification/bloc/notification_info_bloc.dart';
import '../features/superapp/features/notification/bloc/notification_v2_bloc.dart';
import '../features/superapp/features/topup/bloc/check_bill_bloc.dart';
import '../features/superapp/features/topup/bloc/check_qrcode_bloc.dart';
import '../features/superapp/features/topup/bloc/create_invoice_bloc.dart';
import '../features/superapp/features/topup/bloc/create_qrcode_bloc.dart';
import '../features/superapp/features/topup/bloc/expire_qrcode_bloc.dart';

final locator = GetIt.instance;

Future<void> initDependencies() async {
  // inject bloc
  locator.registerFactory(() => CheckEmailBloc(
      checkEmailLoginUseCase: locator(), recaptchaUseCase: locator()));
  locator.registerFactory(() => superapp_auth.LoginBloc(
        checkEmailLoginUseCase: locator(),
        doLoginUseCase: locator(),
        recaptchaUseCase: locator(),
      ));
  locator.registerFactory(
    () => VerificationBloc(resendVerificationUseCase: locator()),
  );

  locator.registerFactory(
      () => BalanceSummaryBloc(getBalanceSummaryUseCase: locator()));
  locator.registerFactory(
      () => RevenuePerformanceBloc(getRevenuePerformanceUseCase: locator()));
  locator.registerFactory(() => ProfileBloc(getProfileUseCase: locator()));
  locator.registerFactory(() => ForgotPasswordBloc(
        sendForgotPasswordUseCase: locator(),
        recaptchaUseCase: locator(),
      ));
  locator.registerFactory(() => InvoiceListBloc(getInvoiceUseCase: locator()));
  locator.registerFactory(() => InvoiceDetailBloc(
      getInvoiceDetailUseCase: locator(),
      downloadInvoiceUseCase: locator(),
      checkTalentEvaluationUseCase: locator()));
  locator.registerFactory(() => RateTalentBloc(
      getTalensUseCase: locator(),
      setRatingTalentsUseCase: locator(),
      getTalentEvaluationsUseCase: locator()));
  locator.registerFactory(() => PinBloc(
        verifyPinUseCase: locator(),
        savePinUseCase: locator(),
        withdrawKompoinUseCase: locator(),
        forgetPinUseCase: locator(),
        verifyOtpUseCase: locator(),
        getProfileUseCase: locator(),
        saveTimeUseCase: locator(),
        getTimeUseCase: locator(),
        deleteTimeUseCase: locator(),
        doPaymentKompayUseCase: locator(),
      ));
  locator.registerFactory(() => TalentListBloc(
      getTalensUseCase: locator(), saveSelectedTalentUseCase: locator()));
  locator.registerFactory(() => TalentListSelectedBloc(
      getSelectedTalensUseCase: locator(),
      updateSelectedTalentsUseCase: locator(),
      sendUnhireTalentsUseCase: locator()));
  locator.registerFactory(() => ShoppingBloc(
      getShoppingListUseCase: locator(),
      getDetailShoppingUseCase: locator(),
      cancelShoppingUseCase: locator(),
      payShoppingUseCase: locator()));

  locator.registerFactory(() => AttendanceBloc(
      getAttendanceUsecase: locator(),
      getAttendanceFailUsecase: locator(),
      getAttedanceAbsenceUsecase: locator(),
      attendanceDownloadUsecase: locator()));

  locator.registerFactory(() => FeedBloc(
        getFeedUseCase: locator(),
        getFeedDetailUseCase: locator(),
      ));

  locator.registerFactory(() => PaymentMethodBloc(
        checkPinUseCase: locator(),
        getInvoiceDetailUseCase: locator(),
        getProfileUseCase: locator(),
        getBalanceAnalyticsUseCase: locator(),
        topUpCeckTransactionUseCase: locator(),
      ));

  locator.registerFactory(() => ReportPerformanceBloc(
        getReportPerformanceUseCase: locator(),
        getReportPerformanceProductUseCase: locator(),
        getReportPerformanceWeeklyUseCase: locator(),
        getReportPerformanceMonthlyUseCase: locator(),
      ));

  locator.registerFactory(() => AplikasikuBloc(
        getAplikasikuListUseCase: locator(),
        resendVerificationUseCase: locator(),
        getLocaleProfileUseCase: locator(),
      ));

  locator.registerFactory(() => CheckBillBloc(checkBillUseCase: locator()));
  locator
      .registerFactory(() => ExpireQrcodeBloc(expireQrcodeUseCase: locator()));
  locator.registerFactory(
      () => ExpireInvoiceBloc(expireInvoiceUseCase: locator()));
  locator.registerFactory(
      () => CreateInvoiceBloc(createInvoiceUseCase: locator()));
  locator.registerFactory(() => CreateQrcodeBloc(useCase: locator()));
  locator.registerFactory(() => CheckQrcodeBloc(useCase: locator()));
  locator.registerFactory(() => NotificationV2Bloc(
        getNotificationV2ListUseCase: locator(),
        readNotificationV2UseCase: locator(),
      ));
  locator.registerFactory(
      () => NotificationInfoBloc(getNotificationInfoUseCase: locator()));

  // inject usecase
  locator.registerLazySingleton(() => RecaptchaUseCase());
  locator.registerLazySingleton(() => CheckEmailLoginUseCase(locator()));
  locator.registerLazySingleton(
      () => DoLoginUseCase(locator(), locator(), locator()));
  locator.registerLazySingleton(() => ResendVerificationUseCase(locator()));
  locator.registerLazySingleton(() => GetAuthStateUseCase(locator()));
  locator.registerLazySingleton(() => DoLogoutUseCase(
        locator(),
        locator(),
        logoutCleanupService: locator(),
      ));
  locator.registerLazySingleton(() => GetProfileUseCase(locator()));
  locator.registerLazySingleton(() => SendForgotPasswordUseCase(locator()));
  locator.registerLazySingleton(() => ChangePasswordUseCase(locator()));
  locator.registerLazySingleton(() => ResetPasswordUseCase(locator()));
  locator.registerLazySingleton(() => GetTalensUseCase(locator()));
  locator.registerLazySingleton(() => GetInvoiceUseCase(locator()));
  locator.registerLazySingleton(() => GetInvoiceDetailUseCase(locator()));
  locator.registerLazySingleton(() => CheckTalentEvaluationUseCase(locator()));
  locator.registerLazySingleton(() => SetRatingTalentsUseCase(locator()));
  locator.registerLazySingleton(() => DownloadInvoiceUseCase(locator()));
  locator.registerLazySingleton(() => GetBankListWithdrawalUseCase(locator()));
  locator.registerLazySingleton(() => CheckPinUseCase(locator()));
  locator.registerLazySingleton(() => VerifyPinUseCase(locator()));
  locator.registerLazySingleton(() => SavePinUseCase(locator()));
  locator.registerLazySingleton(() => TopupKompoinUseCase(locator()));
  locator.registerLazySingleton(() => WithdrawKompoinUseCase(locator()));
  locator.registerLazySingleton(() => GetTransactionHistoryUseCase(locator()));
  locator.registerLazySingleton(
      () => GetTransactionNeedProcessHistoryUseCase(locator()));
  locator.registerLazySingleton(() => GetSelectedTalensUseCase(locator()));
  locator.registerLazySingleton(() => UpdateSelectedTalensUseCase(locator()));
  locator.registerLazySingleton(() => SaveSelectedTalensUseCase(locator()));
  locator.registerLazySingleton(() => SendUnhireTalentsUseCase(locator()));
  locator.registerLazySingleton(() => GetLocaleProfileUseCase(locator()));
  locator.registerLazySingleton(() => GetNotificationsUseCase(locator()));
  locator.registerLazySingleton(() => TopUpUseCase(locator()));
  locator.registerLazySingleton(() => TopUpQrisUseCase(locator()));
  locator.registerLazySingleton(() => TopUpDetailuseCase(locator()));
  locator.registerLazySingleton(() => TopUpCancelUseCase(locator()));
  locator.registerLazySingleton(() => TopUpCeckUseCase(locator()));
  locator.registerLazySingleton(() => ForgetPinUseCase(locator()));
  locator.registerLazySingleton(() => VerifyOtpUseCase(locator()));
  locator.registerLazySingleton(() => SaveTimeUseCase(locator()));
  locator.registerLazySingleton(() => GetTimeUseCase(locator()));
  locator.registerLazySingleton(() => GetShoppingListUseCase(locator()));
  locator.registerLazySingleton(() => GetDetailShoppingUseCase(locator()));
  locator.registerLazySingleton(() => CancelShoppingUseCase(locator()));
  locator.registerLazySingleton(() => PayShoppingUseCase(locator()));
  locator.registerLazySingleton(() => DeleteTimeUseCase(locator()));
  locator.registerLazySingleton(() => GetAttendanceUsecase(locator()));
  locator.registerLazySingleton(() => GetAttendanceFailUsecase(locator()));
  locator.registerLazySingleton(() => GetAttedanceAbsenceUsecase(locator()));
  locator.registerLazySingleton(() => AttendanceDownloadUsecase(locator()));
  locator.registerLazySingleton(() => GetFeedUseCase(locator()));
  locator.registerLazySingleton(() => GetFeedDetailUseCase(locator()));
  locator.registerLazySingleton(() => GetNotifCountUseCase(locator()));
  locator.registerLazySingleton(() => GetNotifReadUseCase(locator()));
  locator.registerLazySingleton(() => DoPaymentKompayUseCase(locator()));
  locator.registerLazySingleton(() => GetBalanceAnalyticsUseCase(locator()));
  locator.registerLazySingleton(() => GetReportPerformanceUseCase(locator()));
  locator.registerLazySingleton(
      () => GetReportPerformanceProductUseCase(locator()));
  locator.registerLazySingleton(
      () => GetReportPerformanceWeeklyUseCase(locator()));
  locator.registerLazySingleton(
      () => GetReportPerformanceMonthlyUseCase(locator()));
  locator
      .registerLazySingleton(() => GetTalentRecommendationUseCase(locator()));
  locator.registerLazySingleton(() => GetIdealBalanceUseCase(locator()));
  locator.registerLazySingleton(() => GetTalentEvaluationsUseCase(locator()));
  locator.registerLazySingleton(() => GetAplikasikuListUseCase(locator()));
  locator.registerLazySingleton(() => CheckBillUseCase(locator()));
  locator.registerLazySingleton(() => ExpireQrcodeUseCase(locator()));
  locator
      .registerLazySingleton(() => ExpireInvoiceUseCase(repository: locator()));
  locator.registerLazySingleton(() => CreateInvoiceUseCase(locator()));
  locator.registerLazySingleton(() => CreateQrcodeUseCase(locator()));
  locator.registerLazySingleton(() => CheckQrcodeUseCase(locator()));

  locator.registerLazySingleton(() => GetBalanceSummaryUseCase(locator()));
  locator.registerLazySingleton(() => GetRevenuePerformanceUseCase(locator()));
  locator.registerLazySingleton(() => GetNotificationV2ListUseCase(locator()));
  locator.registerLazySingleton(() => GetNotificationInfoUseCase(locator()));
  locator.registerLazySingleton(() => ReadNotificationV2UseCase(locator()));

  // inject repository
  locator.registerLazySingleton<BalanceSummaryRepository>(
      () => BalanceSummaryRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<RevenuePerformanceRepository>(
      () => RevenuePerformanceRepositoryImpl(remoteDataSource: locator()));

  locator.registerLazySingleton<AuthRepository>(() =>
      AuthRepositoryImpl(remoteDataSource: locator(), sharedPref: locator()));
  locator.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(
      remoteDataSource: locator(), sharedPref: locator()));
  locator.registerLazySingleton<TalentRepository>(() =>
      TalentRepositoryImpl(remoteDataSource: locator(), sharedPref: locator()));
  locator.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<WithdrawalKompayRepository>(
      () => KompayRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<PinRepository>(() =>
      PinRepositoryImpl(remoteDataSource: locator(), sharedPref: locator()));
  locator.registerLazySingleton<KompoinRepository>(
      () => KompoinRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<TransactionHistoryRepository>(() =>
      TransactionHistoryRepositoryImpl(
          remoteDataSource: locator(), remoteDataSourceNeedProcess: locator()));
  locator.registerLazySingleton<TopUpRepository>(
      () => TopUpRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ShoppingRepository>(() =>
      ShoppingRepositoryImpl(
          remoteDataSource: locator(), sharedPref: locator()));
  locator.registerLazySingleton<AttendanceRepostiory>(
      () => AttendanceRepositoryImp(remoteDataSource: locator()));
  locator.registerLazySingleton<FeedReporsitory>(
      () => FeedReporsitoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ReportPerformanceRepository>(
      () => ReportPerformanceImpl(reportPerformanceDataSource: locator()));

  locator.registerLazySingleton<TalentRecomendationRepository>(
      () => TalentRecomendationRepositoryImpl(
            remoteDataSource: locator(),
          ));
  locator.registerLazySingleton<AplikasikuRepository>(
      () => AplikasikuRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<CheckBillRepository>(
      () => CheckBillRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ExpireQrcodeRepository>(
      () => ExpireQrcodeRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<ExpireInvoiceRepository>(
      () => ExpireInvoiceRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<CreateInvoiceRepository>(
      () => CreateInvoiceRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<CreateQrcodeRepository>(
      () => CreateQrcodeRepositoryImpl(remoteDataSource: locator()));
  locator.registerLazySingleton<CheckQrcodeRepository>(
      () => CheckQrcodeRepositoryImpl(
            remoteDataSource: locator(),
            superappProfileRepository: locator(),
          ));

  locator.registerLazySingleton<SuperappProfileRepositoryImpl>(
      () => SuperappProfileRepositoryImpl(
            remoteDataSource: locator(),
            sharedPreferences: locator.getAsync<SharedPreferences>(),
          ));

  locator.registerLazySingleton<NotificationV2Repository>(
      () => NotificationV2RepositoryImpl(remoteDataSource: locator()));

  // inject datasource
  locator.registerLazySingleton<BalanceSummaryRemoteDataSource>(() =>
      BalanceSummaryRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<RevenuePerformanceRemoteDataSource>(() =>
      RevenuePerformanceRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));

  locator.registerLazySingleton<AuthRemoteDataSource>(() =>
      AuthRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<ProfileRemoteDataSource>(() =>
      ProfileRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<TalentRemoteDataSource>(() =>
      TalentRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<InvoiceRemoteDataSource>(() =>
      InvoiceRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<KompayRemoteDataSource>(() =>
      KompayRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<PinRemoteDataSource>(() =>
      PinRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<KompoinRemoteDataSource>(() =>
      KompoinRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<TransactionHistoryRemoteDataSource>(() =>
      TransactionHistoryRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<TopUpRemoteDataSource>(() =>
      TopUpRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<ShoppingRemoteDataSource>(() =>
      ShoppingRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<AttendanceRemoteDataSource>(() =>
      AttendanceRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<FeedRemoteDataSource>(() =>
      FeedRemoteDataSourceImpl(client: locator(), responseParser: locator()));
  locator.registerLazySingleton<ReportPerformanceDataSource>(() =>
      ReportPerformanceDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<TalentRecomendationRemoteDataSource>(() =>
      TalentRecomendationRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<AplikasikuRemoteDataSource>(() =>
      AplikasikuRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<CheckBillRemoteDataSource>(() =>
      CheckBillRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<ExpireQrcodeRemoteDataSource>(() =>
      ExpireQrcodeRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<ExpireInvoiceRemoteDataSource>(() =>
      ExpireInvoiceRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<CreateInvoiceRemoteDataSource>(() =>
      CreateInvoiceRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<CreateQrcodeRemoteDataSource>(() =>
      CreateQrcodeRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<CheckQrcodeRemoteDataSource>(() =>
      CheckQrcodeRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));
  locator.registerLazySingleton<SuperappProfileRemoteDataSource>(() =>
      SuperappProfileRemoteDataSourceImpl(
          client: locator(), responseParser: locator()));

  locator.registerLazySingleton<NotificationV2RemoteDataSource>(() =>
      NotificationV2RemoteDataSourceImpl(
          client: locator(), responseParser: locator()));

  // Register SharedPreferences
  locator.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());

  // Register SecureStorageService
  locator.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());

  // Register SharedPref
  locator.registerLazySingleton<SharedPref>(() => SharedPref(
        sharedPreferences: locator.getAsync<SharedPreferences>(),
        secureStorage: locator(),
      ));
  locator.registerLazySingleton<TokenProvider>(() => locator<SharedPref>());

  // external

  // Dio Service
  locator.registerLazySingleton(() => AuthInterceptor(
        tokenProvider: locator(),
        authBloc: locator(),
        globalAlertBloc: locator(),
      ));
  locator.registerLazySingleton(() => DioResponseParser());
  locator.registerLazySingleton(() => DioClient(
        sharedPref: locator(),
        authInterceptor: locator(),
      ));

  // Global Blocs
  locator
      .registerLazySingleton<AuthBloc>(() => AuthBloc(sharedPref: locator()));
  locator.registerLazySingleton<GlobalAlertBloc>(() => GlobalAlertBloc());
  // SuperappProfileBloc: lazySingleton, di-init manual setelah allReady()
  // agar AuthBloc & SuperappProfileRepositoryImpl sudah siap
  locator.registerLazySingleton<SuperappProfileBloc>(() => SuperappProfileBloc(
        repository: locator(),
        authBloc: locator(),
      ));

  // Domain Managers
  locator.registerLazySingleton<SharedDataService>(() => SharedDataService());
  locator.registerLazySingleton<LogoutCleanupService>(
      () => FirebaseLogoutCleanupService());

  // Ensure SharedPreferences is ready
  await locator.allReady();

  // Force init SuperappProfileBloc agar tidak miss event dari AuthBloc
  // (karena singleton lazy bisa miss event kalau baru di-init setelah authenticated di-emit)
  locator<SuperappProfileBloc>();
}
