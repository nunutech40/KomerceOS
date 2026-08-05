import '../../../config/config.dart';

class Endpoints {
  // // This is base url
  // // dev
  static String get _BaseURL => Config.instance.baseUrl;
  static String get _BaseURLInternal => Config.instance.baseUrlInternal;
  static String get _BaseURLSuperApp => Config.instance.baseUrlSuperApp;
  static String get _BaseURLKomship => Config.instance.baseUrlKomship;
  static String get _BaseURLTalentPool => Config.instance.baseUrlTalentPool;

  // These are the endpoints

  // Auth Endpoints
  static String get login => '$_BaseURLSuperApp/auth/api/v1/komship/login';
  static String get checkEmail =>
      '$_BaseURLSuperApp/auth/api/v1/auth/check-login';
  static String get resendVerification =>
      '$_BaseURLSuperApp/auth/api/v1/auth/resend-verification';
  static String get refreshToken => '$_BaseURL/api/v1/auth/refresh_token';
  static String get logout => '$_BaseURL/api/v1/auth/logout';
  static String get forgotPassword =>
      '$_BaseURLSuperApp/auth/api/v1/auth/forgot-password';
  static String get changePassword =>
      '$_BaseURL/api/v1/auth/profile/change_password';
  static String get resetPassword =>
      '$_BaseURLSuperApp/auth/api/v1/auth/change-password';
  static String get aplikasiku =>
      '$_BaseURLSuperApp/auth/api/v1/user/aplikasiku';

  // Profile Endpoints
  static String get getProfile => '$_BaseURL/api/v1/auth/profile';
  static String get superappGetProfile =>
      '$_BaseURLSuperApp/auth/api/v1/user/partner/get-profile-mobile';

  // Talents Endpoint
  static String get talents => '$_BaseURL/api/v1/mobile/talents';
  static String get notifications => '$_BaseURL/api/v1/mobile/notifications';

  // Invoice Endpoints
  static String get invoices => '$_BaseURL/api/v1/mobile/invoices';
  static String get invoiceDetail => '$_BaseURL/api/v1/mobile/invoices/detail';
  static String get invoiceDownload =>
      '$_BaseURL/api/v1/mobile/invoices/download';
  static String get setRating => '$_BaseURL/api/v1/mobile/evaluations/store';
  static String get checkEvaluation =>
      '$_BaseURL/api/v1/mobile/evaluations/check_evaluations';

// topup
  static String get bankList =>
      '$_BaseURL/api/v1/mobile/transaction/bank_accounts';
  static String get topUpKompoin => '$_BaseURL/api/v1/mobile/transaction/topup';
  static String get withdrawalKompoin =>
      '$_BaseURL/api/v1/mobile/transaction/withdraw';
  static String get topUpBank => '$_BaseURL/api/v1/mobile/transaction/topup';
  static String get topUpQris =>
      '$_BaseURL/api/v1/mobile/transaction/topup/qris';
  static String get cancelTopUp =>
      '$_BaseURL/api/v1/mobile/transaction/cancel_topup';
  static String get topupDetail => '$_BaseURL/api/v1/mobile/transaction';
  static String get topupCeckTransaction =>
      '$_BaseURL/api/v1/mobile/transaction/check';
  static String get checkBill =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/bill/check-bill/komship';
  static String get createInvoice =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/invoice/create-invoice/komship';
  static String get createQrcode =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/qrcode/create-qrcode/komship';
  static String get checkQrcode =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/qrcode/get-qrcode';
  static String expireQrcode(String id) =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/qrcode/expire-qrcode/$id';
  static String expireInvoice(String id) =>
      '$_BaseURLSuperApp/xendit/api/v1/xendit/invoice/expire-invoice/$id';

// PIN
  static String get checkPinExisting => '$_BaseURL/api/v1/mobile/pin/check';
  static String get verifyPin => '$_BaseURL/api/v1/mobile/pin/verify';
  static String get savePin => '$_BaseURL/api/v1/mobile/pin/save';
  static String get forgetPin =>
      '$_BaseURL/api/v1/mobile/pin/send_forgot_confirmation';
  static String get verifyOtp => '$_BaseURL/api/v1/mobile/otp/verify';

// History
  static String get transactionHistory =>
      '$_BaseURL/api/v1/mobile/transaction/history';
  static String get transactionNeedProcessHistory =>
      '$_BaseURL/api/v1/mobile/transaction/need_process';
  // Unhire Talent
  static String get unhireTalents =>
      '$_BaseURL/api/v1/mobile/talents/request-unhire';

// Shpping
  static String get listShopping => '$_BaseURL/api/v1/mobile/shopping_requests';
  static String get detailShopping =>
      '$_BaseURL/api/v1/mobile/shopping_requests/{id}/detail';
  static String get cancelShopping =>
      '$_BaseURL/api/v1/mobile/shopping_requests/{id}/cancel';
  static String get payShopping =>
      '$_BaseURL/api/v1/mobile/shopping_requests/pay';

// Attendance
  static String get listAttendance => '$_BaseURL/api/v1/mobile/presences/list';
  static String get listAttendanceFail =>
      '$_BaseURL/api/v1/mobile/presences/ticket/list';
  static String get listAttendanceAbsence =>
      '$_BaseURL/api/v1/mobile/presences/absences/list';
  static String get attendanceDownload =>
      '$_BaseURL/api/v1/mobile/presences/export';

//Feed
  static String get listFeed => '$_BaseURL/api/v1/mobile/news';
  static String get listFeedDetail => '$_BaseURL/api/v1/mobile/news';

//Notification
  static String get notificationsRead =>
      '$_BaseURL/api/v1/mobile/notifications';
  static String get notificationsCount =>
      '$_BaseURL/api/v1/mobile/notifications/count';
  static String get superappNotificationsList =>
      '$_BaseURLSuperApp/komship/api/v1/notifications/v2/list';
  static String get superappNotificationInfo =>
      '$_BaseURLSuperApp/komship/api/v1/notifications/info';
  static String superappReadNotification(int id) =>
      '$_BaseURLSuperApp/komship/api/v1/notifications/$id/read';

  //paymentKompay
  static String get paymentKompay =>
      '$_BaseURL/api/v1/mobile/transaction/kompay';
  static String get transactionBalance =>
      '$_BaseURLInternal/api/v1/kmpoin/balance_analytics';

  // Talents Recomendation Endpoint
  static String get talentRecomendation =>
      '$_BaseURL/api/v1/mobile/talent_pool/talents';

  // Business Sector (Resource) Endpoint
  static String get businessSector =>
      '$_BaseURLTalentPool/api/v1/resource/business_sector';

  // Resource Talents (Talent Pool listing with filter)
  static String get resourceTalents =>
      '$_BaseURLTalentPool/api/v1/resource/talents';
  // Report Performance
  static String get reportPerformance =>
      '$_BaseURL/api/v1/mobile/talent_performance/list';
  static String get productReportPerformance =>
      '$_BaseURL/api/v1/mobile/partners/products';
  static String get weeklyReportPerformance =>
      '$_BaseURL/api/v1/mobile/talent_performance/weekly';
  static String get monthlyReportPerformance =>
      '$_BaseURL/api/v1/mobile/talent_performance/monthly';

  // Balance Summary
  static String balanceSummary(String partnerId) =>
      '$_BaseURLKomship/api/v1/dashboard/partner/balanceSummary?partner_id=$partnerId';
  static String get revenueOrderPerformance =>
      '$_BaseURLKomship/api/v1/dashboard/partner/revenueOrderPerformance';
}
