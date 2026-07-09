import 'package:equatable/equatable.dart';

class TopupKompoinModel extends Equatable {
  int transactionId;
  int transactionNominal;
  String transactionPaymentUrl;

  TopupKompoinModel(
      {required this.transactionId,
      required this.transactionNominal,
      required this.transactionPaymentUrl});

  @override
  List<Object?> get props => [
        transactionId,
        transactionNominal,
        transactionPaymentUrl,
      ];
}
