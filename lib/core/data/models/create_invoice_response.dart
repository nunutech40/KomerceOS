import 'package:equatable/equatable.dart';
import '../../domain/entities/create_invoice_model.dart';

class CreateInvoiceResponse extends Equatable {
  final String? id;
  final String? userId;
  final String? invoiceUrl;

  const CreateInvoiceResponse({
    required this.id,
    required this.userId,
    required this.invoiceUrl,
  });

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return CreateInvoiceResponse(
      id: json['id'],
      userId: json['user_id'],
      invoiceUrl: json['invoice_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "invoice_url": invoiceUrl,
      };

  CreateInvoiceModel toEntity() {
    return CreateInvoiceModel(
      id: id,
      userId: userId,
      invoiceUrl: invoiceUrl,
    );
  }

  @override
  List<Object?> get props => [id, userId, invoiceUrl];
}
