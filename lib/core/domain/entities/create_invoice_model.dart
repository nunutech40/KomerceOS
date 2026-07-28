import 'package:equatable/equatable.dart';

class CreateInvoiceModel extends Equatable {
  final String? id;
  final String? userId;
  final String? invoiceUrl;

  const CreateInvoiceModel({
    required this.id,
    required this.userId,
    required this.invoiceUrl,
  });

  @override
  List<Object?> get props => [id, userId, invoiceUrl];
}
