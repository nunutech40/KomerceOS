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
        id: (dataJson['id'] ??
                dataJson['qr_xendit_id'] ??
                dataJson['xendit_id'] ??
                dataJson['external_id'] ??
                dataJson['qr_id'] ??
                dataJson['reference_id'] ??
                json['id'] ??
                json['qr_xendit_id'])
            ?.toString(),
        channelCode: dataJson['channel_code']?.toString(),
        amount: dataJson['amount'] != null
            ? int.tryParse(dataJson['amount'].toString())
            : null,
        expiresAt: dataJson['expires_at']?.toString(),
        qrString: dataJson['qr_string']?.toString(),
      ),
    );
  }
}
