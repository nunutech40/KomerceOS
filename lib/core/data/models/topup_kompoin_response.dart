import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/topup_kompoin_model.dart';

class TopupKompoinResponse extends Equatable {
  final int transactionId;
  final int transactionNominal;
  final String transactionPaymentUrl;

  const TopupKompoinResponse(
      {required this.transactionId,
      required this.transactionNominal,
      required this.transactionPaymentUrl});

  Map<String, dynamic> toJson() => {
        "transaction_id": transactionId,
        "transaction_nominal": transactionNominal,
        "transaction_payment_url": transactionPaymentUrl,
      };

  factory TopupKompoinResponse.fromJson(Map<String, dynamic> json) {
    return TopupKompoinResponse(
      transactionId: json['transaction_id'],
      transactionNominal: json['transaction_nominal'],
      transactionPaymentUrl: json['transaction_payment_url'],
    );
  }

  TopupKompoinModel toEntity() {
    return TopupKompoinModel(
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
