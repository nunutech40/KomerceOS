import 'package:equatable/equatable.dart';

import 'partner_product_model.dart';

// -----------------------------------------------------------------------------
// CheckEmailModel (Entity — Domain Layer)
//
// Merepresentasikan hasil pengecekan email login.
// allowed_login == true  → lanjut ke LoginPage
// allowed_login == false → tampilkan VerificationRequiredPage
// -----------------------------------------------------------------------------

class CheckEmailModel extends Equatable {
  final bool? allowedLogin;
  final bool? banned;
  final String? email;
  final List<PartnerProductModel> partnerProducts;

  const CheckEmailModel({
    this.allowedLogin,
    this.banned,
    this.email,
    this.partnerProducts = const [],
  });

  /// Email terdaftar dan boleh login (setidaknya 1 produk terverifikasi)
  bool get isAllowedLogin => allowedLogin == true;

  /// Akun di-banned oleh admin
  bool get isBanned => banned == true;

  /// Email terdaftar tapi belum ada produk yang terverifikasi (dan tidak di-banned)
  bool get isNotAllowedLogin => allowedLogin == false && banned != true;

  /// Daftar produk yang belum terverifikasi
  List<PartnerProductModel> get unverifiedProducts =>
      partnerProducts.where((p) => p.isVerified == false).toList();

  @override
  List<Object?> get props => [allowedLogin, banned, email, partnerProducts];
}
