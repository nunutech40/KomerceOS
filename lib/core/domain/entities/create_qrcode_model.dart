class CreateQrcodeModel {
  final String? id;
  final String? channelCode;
  final int? amount;
  final String? expiresAt;
  final String? qrString;

  CreateQrcodeModel({
    this.id,
    this.channelCode,
    this.amount,
    this.expiresAt,
    this.qrString,
  });
}
