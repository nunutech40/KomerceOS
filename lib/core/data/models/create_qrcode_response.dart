import '../../domain/entities/create_qrcode_model.dart';

class CreateQrcodeResponse {
  final String? status;
  final int? code;
  final String? message;
  final CreateQrcodeModel data;

  CreateQrcodeResponse({
    this.status,
    this.code,
    this.message,
    required this.data,
  });

  factory CreateQrcodeResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};
    return CreateQrcodeResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: CreateQrcodeModel(
        id: dataJson['id'],
        channelCode: dataJson['channel_code'],
        amount: dataJson['amount'],
        expiresAt: dataJson['expires_at'],
        qrString: dataJson['qr_string'],
      ),
    );
  }
}
