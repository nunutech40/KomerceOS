import 'package:equatable/equatable.dart';

class TopUpQrisModel extends Equatable {
  final int transactionId;
  final String transactionCode;
  final int transactionNominal;
  final String transactionQrisCode;
  final String createdAt;
  final String updatedAt;
  final String expiredAt;

  const TopUpQrisModel({
    required this.transactionId,
    required this.transactionCode,
    required this.transactionNominal,
    required this.transactionQrisCode,
    required this.createdAt,
    required this.updatedAt,
    required this.expiredAt,
  });

  @override
  List<Object?> get props => [
        transactionId,
        transactionCode,
        transactionNominal,
        transactionCode,
        expiredAt,
        createdAt,
        updatedAt,
      ];
}
