import '../../../config/config.dart';

class Endpoints {
  // // This is base url
  // // dev
  static String get _BaseURL => Config.instance.baseUrl;
  static String get _BaseURLInternal => Config.instance.baseUrlInternal;
  static String get _BaseURLSuperApp => Config.instance.baseUrlSuperApp;
  static String get _BaseURLKomship => Config.instance.baseUrlKomship;
  static String get _BaseURLKomshipHiring =>
      Config.instance.baseUrlKomshipHiring;
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
      '$_BaseURLInternal/api/v1/user/partner/get-profile-mobile';
  static String get superappUpdateUserProfile =>
      '$_BaseURLInternal/api/v1/user/partner/profile-user';
  static String get superappUpdateBusinessProfile =>
      '$_BaseURLInternal/api/v1/user/partner/profile-business';

  // Legacy Komship profile APIs. These intentionally use the Komship host,
  // which is different from the Super App auth/profile host.
  static String get komshipProfile => '$_BaseURLKomship/api/v1/my-profile';
  static String get komshipUpdateAccountProfile =>
      '$_BaseURLKomshipHiring/api/user/v2/partner/update-profile-komship';
  static String get komshipUpdateEmail =>
      '$_BaseURLKomshipHiring/api/user/partner/update-profile/email';
  static String get komshipUpdateBusinessProfile =>
      '$_BaseURLKomshipHiring/api/user/v2/partner/update-profile-komship';
  static String get komshipBusinessTypes =>
      '$_BaseURLKomshipHiring/api/v2/business-type';
  static String get komshipBusinessSectors =>
      '$_BaseURLKomshipHiring/api/v2/partner-category';
  static String get komshipLocations =>
      '$_BaseURLKomshipHiring/api/v1/partner/province-city';

  // Talents Endpoint
  static String get talents => '$_BaseURL/api/v1/mobile/talents';
  static String get notifications => '$_BaseURL/api/v1/mobile/notifications';

  // Invoice Endpoints
  static String get invoices => '$_BaseURL/api/v1/mobile/invoices';
  static String get invoiceDetail => '$_BaseURL/api/v1/mobile/invoices/detail';
  static String get invoiceDownload =>
      '$_BaseURL/api/v1/mobile/invoices/download';
  static String get setRating => '$_BaseURL/api/v1/evaluations';
  static String get checkEvaluation =>
      '$_BaseURL/api/v1/evaluations/check_evaluations';

// topup
  static String get bankList =>
      '$_BaseURL/api/v1/mobile/transaction/bank_accounts';
  static String get komshipBankAccounts =>
      '$_BaseURLKomship/api/v1/bank-account';
  static String get komshipAvailableBanks =>
      '$_BaseURLKomshipHiring/api/xendit/disbursementbankAvailable';
  static String get komshipCheckBankOwner =>
      '$_BaseURLKomshipHiring/api/v1/bank/check-bank-owner';
  static String get komshipCheckBankAlready =>
      '$_BaseURLKomshipHiring/api/v1/bank/check';
  static String get komshipCheckWhatsApp => '$_BaseURLKomship/api/v1/check-wa';
  static String get securedAddBankAccount =>
      '$_BaseURLInternal/api/v1/otp/secured/user/add-rekening';
  static String get otpRequestPhone =>
      '$_BaseURLInternal/api/v1/otp/request-otp/phone';
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
  static String get checkPinExisting => '$_BaseURLKomship/api/v1/pin/check';
  static String get verifyPin => '$_BaseURL/api/v1/mobile/pin/verify';
  static String get savePin => '$_BaseURL/api/v1/mobile/pin/save';
  static String get forgetPin =>
      '$_BaseURL/api/v1/mobile/pin/send_forgot_confirmation';
  static String get verifyOtp => '$_BaseURL/api/v1/mobile/otp/verify';

  // Komship exposes PIN status here; the internal setting/pin GET does not exist.
  static String get checkPinSetting => checkPinExisting;
  static String get storePinSetting =>
      '$_BaseURLInternal/api/v1/user/setting/pin/store';

  // PIN & OTP (internal auth API)
  static String get securedVerifyPin =>
      '$_BaseURLInternal/api/v1/user/secured/verify-pin';
  static String get pinAttemptLeft =>
      '$_BaseURLInternal/api/v1/user/secured/verify-pin/attempt-left';
  static String get updatePinSetting =>
      '$_BaseURLInternal/api/v1/user/setting/pin/update';
  static String get otpRequestEmail =>
      '$_BaseURLInternal/api/v1/otp/request-otp/email';
  static String get otpVerify => '$_BaseURLInternal/api/v1/otp/verify-otp';
  static String get securedUpdatePin =>
      '$_BaseURLInternal/api/v1/otp/secured/user/update-pin';

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
  static String get paymentKompay => '$_BaseURL/api/v1/partner/invoices/pay';
  static String get transactionBalance =>
      '$_BaseURLInternal/api/v1/kmpoin/balance_analytics';

  // Talents Recomendation Endpoint
  static String get talentRecomendation =>
      '$_BaseURL/api/v1/mobile/talent_pool/talents';

  // Business Sector (Resource) Endpoint
  static String get businessSector =>
      '$_BaseURLTalentPool/api/v1/resource/business_sector';

  // Team Endpoints
  static String get internalTeams => '$_BaseURLSuperApp/auth/api/v1/teams';
  static String get komtimTeams => '$_BaseURLSuperApp/auth/api/v1/komtim/teams';

  // Resource Talents (Talent Pool listing with filter)
  static String get resourceTalents =>
      '$_BaseURLTalentPool/api/v1/resource/talents';

  // Wishlist Talent
  static String putWishlist(int talentId) =>
      '$_BaseURLTalentPool/api/v1/auth/wishlist/$talentId';
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
