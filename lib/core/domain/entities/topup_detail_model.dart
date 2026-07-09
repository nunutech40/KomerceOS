import 'package:equatable/equatable.dart';

class TopUpDetailModel extends Equatable {
  int? transactionId;
  String? transactionType;
  String? transactionCode;
  String? transactionDate;
  int? transactionNominal;
  String? transactionQrisCode;
  String? transactionPaymentUrl;
  String? transactionTopupType;
  String? transactionStatus;
  String? expiredAt;
  String? createdAt;
  String? updatedAt;
  TopUpDetailModel(
      {this.transactionId,
      this.transactionType,
      this.transactionCode,
      this.transactionDate,
      this.transactionNominal,
      this.transactionQrisCode,
      this.transactionPaymentUrl,
      this.transactionTopupType,
      this.transactionStatus,
      this.expiredAt,
      this.createdAt,
      this.updatedAt});

  @override
  List<Object?> get props => [
        transactionId,
        transactionType,
        transactionCode,
        transactionDate,
        transactionNominal,
        transactionQrisCode,
        transactionPaymentUrl,
        transactionTopupType,
        transactionStatus,
        expiredAt,
        createdAt,
        updatedAt,
      ];
}
