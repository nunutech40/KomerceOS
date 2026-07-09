import 'package:equatable/equatable.dart';

class TopupQRISResponse extends Equatable {
  final int transactionId;
  final String transactionCode;
  final int? transactionNominal;
  final int? transactionAmountAdmin;
  final int? transactionTotal;
  final String transactionQrisCode;
  final String createdAt;
  final String updatedAt;
  final String expiredAt;

  const TopupQRISResponse({
    required this.transactionId,
    required this.transactionCode,
    required this.transactionNominal,
    required this.transactionAmountAdmin,
    required this.transactionTotal,
    required this.transactionQrisCode,
    required this.createdAt,
    required this.updatedAt,
    required this.expiredAt,
  });

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transaction_code": transactionCode,
        "transaction_nominal": transactionNominal,
        "transaction_amount_admin": transactionAmountAdmin,
        "transaction_total": transactionTotal,
        "transaction_qris_code": transactionQrisCode,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "expired_at": expiredAt,
      };

  factory TopupQRISResponse.fromJson(Map<String, dynamic> json) {
    return TopupQRISResponse(
      transactionId: json['transaction_id'],
      transactionCode: json['transaction_code'],
      transactionNominal: json['transaction_nominal'],
      transactionAmountAdmin: json['transaction_amount_admin'],
      transactionTotal: json['transaction_total'],
      transactionQrisCode: json['transaction_qris_code'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expiredAt: json['expired_at'],
    );
  }

  TopupQRISResponse toEntity() {
    return TopupQRISResponse(
      transactionId: transactionId,
      transactionCode: transactionCode,
      transactionNominal: transactionNominal,
      transactionAmountAdmin: transactionAmountAdmin,
      transactionTotal: transactionTotal,
      transactionQrisCode: transactionQrisCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiredAt: expiredAt,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        transactionCode,
        transactionNominal,
        transactionAmountAdmin,
        transactionTotal,
        transactionCode,
        createdAt,
        updatedAt,
        expiredAt
      ];
}

class TopupDetailResponse extends Equatable {
  int? transactionId;
  String? transactionType;
  String? transactionCode;
  String? transactionDate;
  int? transactionNominal;
  int? transactionAmountAdmin;
  int? transactionTotal;
  String? transactionQrisCode;
  String? transactionPaymentUrl;
  String? transactionTopupType;
  String? transactionStatus;
  String? expiredAt;
  String? createdAt;
  String? updatedAt;
  TopupDetailResponse(
      {this.transactionId,
      this.transactionType,
      this.transactionCode,
      this.transactionDate,
      this.transactionNominal,
      this.transactionAmountAdmin,
      this.transactionTotal,
      this.transactionQrisCode,
      this.transactionPaymentUrl,
      this.transactionTopupType,
      this.transactionStatus,
      this.expiredAt,
      this.createdAt,
      this.updatedAt});

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transaction_type": transactionType,
        "transaction_code": transactionCode,
        "transaction_date": transactionDate,
        "transaction_nominal": transactionNominal,
        "transaction_amount_admin": transactionAmountAdmin,
        "transaction_total": transactionTotal,
        "transaction_qris_code": transactionQrisCode,
        "transaction_payment_url": transactionPaymentUrl,
        "transaction_topup_type": transactionTopupType,
        "transaction_status": transactionStatus,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "expired_at": expiredAt,
      };

  factory TopupDetailResponse.fromJson(Map<String, dynamic> json) {
    return TopupDetailResponse(
      transactionId: json['transaction_id'],
      transactionType: json['transaction_type'],
      transactionCode: json['transaction_code'],
      transactionDate: json['transaction_date'],
      transactionNominal: json['transaction_nominal'],
      transactionAmountAdmin: json['transaction_amount_admin'],
      transactionTotal: json['transaction_total'],
      transactionQrisCode: json['transaction_qris_code'],
      transactionPaymentUrl: json['transaction_payment_url'],
      transactionTopupType: json['transaction_topup_type'],
      transactionStatus: json['transaction_status'],
      expiredAt: json['expired_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  TopupDetailResponse toEntity() {
    return TopupDetailResponse(
      transactionId: transactionId,
      transactionType: transactionType,
      transactionCode: transactionCode,
      transactionDate: transactionDate,
      transactionNominal: transactionNominal,
      transactionAmountAdmin: transactionAmountAdmin,
      transactionTotal: transactionTotal,
      transactionQrisCode: transactionQrisCode,
      transactionPaymentUrl: transactionPaymentUrl,
      transactionTopupType: transactionTopupType,
      transactionStatus: transactionStatus,
      expiredAt: expiredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        transactionType,
        transactionCode,
        transactionDate,
        transactionNominal,
        transactionAmountAdmin,
        transactionTotal,
        transactionQrisCode,
        transactionPaymentUrl,
        transactionTopupType,
        transactionStatus,
        expiredAt,
        createdAt,
        updatedAt,
      ];
}
