import 'package:equatable/equatable.dart';

import '../../domain/entities/check_email_model.dart';
import '../../domain/entities/partner_product_model.dart';

// -----------------------------------------------------------------------------
// PartnerProductResponse (Data Layer)
//
// Model untuk item di dalam list partner_products pada response check-login.
// -----------------------------------------------------------------------------

class PartnerProductResponse extends Equatable {
  final int? id;
  final String? productName;
  final bool? isVerified;
  final String? urlLogo;

  const PartnerProductResponse({
    this.id,
    this.productName,
    this.isVerified,
    this.urlLogo,
  });

  factory PartnerProductResponse.fromJson(Map<String, dynamic> json) {
    return PartnerProductResponse(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id'] ?? ''}'),
      productName: json['product_name'],
      isVerified: json['is_verified'],
      urlLogo: json['url_logo'],
    );
  }

  PartnerProductModel toEntity() {
    return PartnerProductModel(
      id: id,
      productName: productName,
      isVerified: isVerified,
      urlLogo: urlLogo,
    );
  }

  @override
  List<Object?> get props => [id, productName, isVerified, urlLogo];
}

// -----------------------------------------------------------------------------
// CheckEmailResponse (Data Layer)
//
// Response dari API /auth/api/v1/auth/check-login
// Membaca allowed_login dan partner_products dari response body.
// -----------------------------------------------------------------------------

class CheckEmailResponse extends Equatable {
  final bool? allowedLogin;
  final bool? banned;
  final String? email;
  final List<PartnerProductResponse> partnerProducts;

  const CheckEmailResponse({
    this.allowedLogin,
    this.banned,
    this.email,
    this.partnerProducts = const [],
  });

  factory CheckEmailResponse.fromJson(dynamic jsonData) {
    // DioResponseParser sudah mempassing data['data'], jadi jsonData adalah
    // langsung isi dari key 'data'.
    final Map<String, dynamic> data =
        jsonData is Map<String, dynamic> ? jsonData : {};

    final List<PartnerProductResponse> products = [];
    final rawProducts = data['partner_products'];
    if (rawProducts is List) {
      for (final item in rawProducts) {
        if (item is Map<String, dynamic>) {
          products.add(PartnerProductResponse.fromJson(item));
        }
      }
    }

    return CheckEmailResponse(
      allowedLogin: data['allowed_login'],
      banned: data['banned'],
      email: data['email'],
      partnerProducts: products,
    );
  }

  CheckEmailModel toEntity() {
    return CheckEmailModel(
      allowedLogin: allowedLogin,
      banned: banned,
      email: email,
      partnerProducts: partnerProducts.map((p) => p.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [allowedLogin, banned, email, partnerProducts];
}
