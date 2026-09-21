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
    // DioResponseParser may pass the full envelope or just the 'data' object.
    // If json contains 'data' as a Map, use it; otherwise treat json itself as data.
    final dataJson = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    return CreateQrcodeResponse(
      status: json['status']?.toString(),
      code: json['code'] is int ? json['code'] : null,
      message: json['message']?.toString(),
      data: CreateQrcodeModel(
        id: (dataJson['id'] ??
                dataJson['qr_xendit_id'] ??
                dataJson['xendit_id'] ??
                dataJson['external_id'] ??
                dataJson['qr_id'] ??
                dataJson['reference_id'])
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
