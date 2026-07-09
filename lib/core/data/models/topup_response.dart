import 'package:equatable/equatable.dart';

class TopupResponse extends Equatable {
  final int transactionId;
  final int transactionNominal;
  final String transactionPaymentUrl;

  const TopupResponse(
      {required this.transactionId,
      required this.transactionNominal,
      required this.transactionPaymentUrl});

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transaction_nominal": transactionNominal,
        "transaction_payment_url": transactionPaymentUrl,
      };

  factory TopupResponse.fromJson(Map<String, dynamic> json) {
    return TopupResponse(
      transactionId: json['transaction_id'],
      transactionNominal: json['transaction_nominal'],
      transactionPaymentUrl: json['transaction_payment_url'],
    );
  }

  TopupResponse toEntity() {
    return TopupResponse(
        transactionId: transactionId,
        transactionNominal: transactionNominal,
        transactionPaymentUrl: transactionPaymentUrl);
  }

  @override
  List<Object?> get props => [
        transactionId,
        transactionNominal,
        transactionPaymentUrl,
      ];
}
