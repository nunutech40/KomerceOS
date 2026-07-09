enum PAGES {
  splash,
  // auth
  emailCheck,
  login,
  forgotPasswrod,
  newForgotPassword,
  successNewPassword,
  authOtp,
  changePassword,
  // home
  main,
  notification,
  // other
  error,
  // prifile
  profileInfo,
  // invoice
  invoiceList,
  invoiceReportSummary,
  rateTalentNotifPage,
  rateTalentCheckPage,
  evaluationKompointPage,

  // kompoy
  withdrawKompoyPage,
  successPage,

  // pin
  pinPage,
  //unhire talent
  unhirePage,
  //reason unhire
  reasonUnhirePage,
  //dialog unhire
  dialogUnhireFinish,

  //topup pages
  topuppages,

  //QrisPayment
  qrispayment,
  bankpayment,
  //otp verification
  pinOtpVerification,

  //shopping list
  shoppingListPage,
  //detail shopping
  detailShoppingPage,
  //force update
  forceUpdatePage,
  attendance,
  feed,
  feeddetail,

  //payment method
  paymentmethod,
  successPayment,

  //reportperformance
  reportperformance,
  reportdetailperformance,

}

extension AppPageExtension on PAGES {
  String get screenPath {
    switch (this) {
      case PAGES.main:
        return "/";
      case PAGES.splash:
        return "/splash";
      case PAGES.emailCheck:
        return "/email_check";
      case PAGES.login:
        return "/login";
      case PAGES.notification:
        return "/notifications";
      case PAGES.forgotPasswrod:
        return "/forgot_password";
      case PAGES.newForgotPassword:
        return "/reset-password";
      case PAGES.successNewPassword:
        return "/success_new_password";
      case PAGES.authOtp:
        return "/auth_otp";
      case PAGES.changePassword:
        return "/change_password";
      case PAGES.error:
        return "/error";
      case PAGES.profileInfo:
        return "/profile_info";
      // invoice
      case PAGES.invoiceList:
        return "/invoice_list";
      case PAGES.invoiceReportSummary:
        return "/invoice_summary_report";
      case PAGES.rateTalentNotifPage:
        return "/rate_talent_notif_page";
      case PAGES.rateTalentCheckPage:
        return "/rate_talent_check_page";
      case PAGES.evaluationKompointPage:
        return "/evaluation_kompoint_page";
      case PAGES.withdrawKompoyPage:
        return "/withdraw_kompoy_page";
      case PAGES.successPage:
        return "/success_withdrawal_page";
      case PAGES.pinPage:
        return "/pin_page";
      case PAGES.unhirePage:
        return "/unhire_page";
      case PAGES.reasonUnhirePage:
        return "/reason_unhire_page";
      case PAGES.dialogUnhireFinish:
        return "/dialog_unhire_finish";

      case PAGES.topuppages:
        return "/topup_pages";
      case PAGES.qrispayment:
        return "/qrispayment";
      case PAGES.bankpayment:
        return "/bankpayment";
      case PAGES.pinOtpVerification:
        return "/verification_email_page";
      case PAGES.shoppingListPage:
        return "/shopping_list_page";
      case PAGES.detailShoppingPage:
        return "/detail_shopping_page";
      case PAGES.forceUpdatePage:
        return "/force_update_page";
      case PAGES.attendance:
        return "/attendance_pages";
      case PAGES.feed:
        return "/feed";
      case PAGES.feeddetail:
        return "/feed_detail";
      case PAGES.paymentmethod:
        return "/payment_method";
      case PAGES.successPayment:
        return "/success_payment";
      case PAGES.reportperformance:
        return "/report_performance";
      case PAGES.reportdetailperformance:
        return "/report_detail_performance";
    }
  }

  String get screenName {
    switch (this) {
      case PAGES.main:
        return "HOME";
      case PAGES.emailCheck:
        return "EMAIL CHECK";
      case PAGES.login:
        return "LOGIN";
      case PAGES.forgotPasswrod:
        return "FORGOT PASSWORD";
      case PAGES.newForgotPassword:
        return "NEW FORGOT PASSWORD";
      case PAGES.successNewPassword:
        return "SUCCESS NEW PASSWORD";
      case PAGES.authOtp:
        return "AUTH OTP";
      case PAGES.notification:
        return "NOTIFICATIONS";
      case PAGES.changePassword:
        return "CHANGE PASSWORD";
      case PAGES.splash:
        return "SPLASH";
      case PAGES.error:
        return "ERROR";
      case PAGES.profileInfo:
        return "PROFILE INFO";
      case PAGES.invoiceList:
        return "INVOICE LIST";
      case PAGES.invoiceReportSummary:
        return "INVOICEREPORT SUMMARY";
      case PAGES.rateTalentNotifPage:
        return "RATETALENT NOTIF PAGE";
      case PAGES.rateTalentCheckPage:
        return "RATE TALENT CHECKPAGE";
      case PAGES.evaluationKompointPage:
        return "Evaluation Kompoint Page";
      case PAGES.withdrawKompoyPage:
        return "WITHDRAW KOMPOY PAGE";
      case PAGES.successPage:
        return "SUCCESS PAGE";
      case PAGES.pinPage:
        return "PIN PAGE";
      case PAGES.unhirePage:
        return "UNHIRE PAGE";
      case PAGES.reasonUnhirePage:
        return "REASON UNHIRE PAGE";
      case PAGES.dialogUnhireFinish:
        return "DIALOG INHIRE FINISH";
      case PAGES.topuppages:
        return "TOP UP PAGES";
      case PAGES.qrispayment:
        return "QRIS PAYMENT PAGES";
      case PAGES.bankpayment:
        return "BANK PAYMENT PAGES";
      case PAGES.pinOtpVerification:
        return "PIN OTP VERIFICATION";
      case PAGES.shoppingListPage:
        return "SHOPPING LIST PAGE";
      case PAGES.detailShoppingPage:
        return "DETAIL SHOPPING PAGE";
      case PAGES.forceUpdatePage:
        return "FORCE UPDATE PAGE";
      case PAGES.attendance:
        return "ATTENDANCE PAGE";
      case PAGES.feed:
        return "FEED PAGE";
      case PAGES.feeddetail:
        return "FEED DETAIL PAGE";
      case PAGES.paymentmethod:
        return "PAYMENT METHOD PAGE";
      case PAGES.successPayment:
        return "SUCCESS PAYMENT PAGE";
      case PAGES.reportperformance:
        return "REPORT PERFORMANCE PAGE";
      case PAGES.reportdetailperformance:
        return "REPORT DETAIL PERFORMANCE PAGE";
    }
  }

  String get screenTitle {
    switch (this) {
      case PAGES.main:
        return "Home";
      case PAGES.emailCheck:
        return "Email Check";
      case PAGES.login:
        return "Login";
      case PAGES.forgotPasswrod:
        return "Forgot Password";
      case PAGES.changePassword:
        return "Change Password";
      case PAGES.notification:
        return "Notifications";
      case PAGES.splash:
        return "Splash";
      case PAGES.profileInfo:
        return "Profile Info";
      case PAGES.error:
        return "Error";
      case PAGES.invoiceList:
        return "Invoice";
      case PAGES.invoiceReportSummary:
        return "Invoice Report Summary";
      case PAGES.rateTalentNotifPage:
        return "Rate Talent Notif Page";
      case PAGES.rateTalentCheckPage:
        return "Rate Talent Check Page";
      case PAGES.withdrawKompoyPage:
        return "Withdraw Kompoy Page";
      case PAGES.successPage:
        return "Success Page";
      case PAGES.pinPage:
        return "Pin Page";
      case PAGES.unhirePage:
        return "Unhire Page";
      case PAGES.reasonUnhirePage:
        return "Reason Unhire Page";
      case PAGES.dialogUnhireFinish:
        return "Dialog Unhire Finish";
      case PAGES.topuppages:
        return "Top Up Pages";
      case PAGES.qrispayment:
        return "QRIS PAYMENT Pages";
      case PAGES.bankpayment:
        return "Bank PAYMENT Pages";
      case PAGES.pinOtpVerification:
        return "Pin Otp Verification";
      case PAGES.shoppingListPage:
        return "Shopping List Page";
      case PAGES.detailShoppingPage:
        return "Detail Shopping Page";
      case PAGES.forceUpdatePage:
        return "force update page";
      case PAGES.attendance:
        return "Attendance Page";
      case PAGES.feed:
        return "Feed Page";
      case PAGES.feeddetail:
        return "Feed Detail Page";
      case PAGES.paymentmethod:
        return "Payment Method Page";
      case PAGES.successPayment:
        return "Success Payment Page";
      case PAGES.reportperformance:
        return "Report Performancane Page";
      case PAGES.reportdetailperformance:
        return "Report Detail Performancane Page";
      default:
        return "Home";
    }
  }
}
