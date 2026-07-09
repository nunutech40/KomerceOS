import 'package:equatable/equatable.dart';

// -----------------------------------------------------------------------------
// PartnerProductModel (Entity — Domain Layer)
//
// Merepresentasikan satu produk partner dalam response check-login.
// -----------------------------------------------------------------------------

class PartnerProductModel extends Equatable {
  final int? id;
  final String? productName;
  final bool? isVerified;
  final String? urlLogo;

  const PartnerProductModel({
    this.id,
    this.productName,
    this.isVerified,
    this.urlLogo,
  });

  @override
  List<Object?> get props => [id, productName, isVerified, urlLogo];
}
