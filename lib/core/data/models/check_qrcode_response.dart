import '../../domain/entities/check_qrcode_model.dart';

class CheckQrcodeResponse {
  final String? status;
  final int? code;
  final String? message;
  final CheckQrcodeModel data;

  CheckQrcodeResponse({
    this.status,
    this.code,
    this.message,
    required this.data,
  });

  factory CheckQrcodeResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};
    return CheckQrcodeResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: CheckQrcodeModel(
        id: dataJson['id'],
        qrXenditId: dataJson['qr_xendit_id'],
        statusPayment: dataJson['status_payment'],
        amount: dataJson['amount'],
      ),
    );
  }
}
