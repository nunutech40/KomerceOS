import 'package:equatable/equatable.dart';
import '../../domain/entities/check_bill_model.dart';

class CheckBillResponse extends Equatable {
  final bool? haveActiveBill;
  final String? invoiceExternalId;
  final String? invoiceXenditId;
  final String? invoiceXenditUrl;
  final String? qrExternalId;
  final String? qrXenditId;
  final String? qrXenditQrstring;
  final String? qrExpireDate;
  final int? qrAmount;
  final int? invoiceAmount;
  final int? adminFee;

  const CheckBillResponse({
    this.haveActiveBill,
    this.invoiceExternalId,
    this.invoiceXenditId,
    this.invoiceXenditUrl,
    this.qrExternalId,
    this.qrXenditId,
    this.qrXenditQrstring,
    this.qrExpireDate,
    this.qrAmount,
    this.invoiceAmount,
    this.adminFee,
  });

  factory CheckBillResponse.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return const CheckBillResponse(haveActiveBill: false);
    }
    final map = json as Map<String, dynamic>;

    bool? parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) {
        final lower = val.toLowerCase();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      return false;
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val.split('.').first);
      return null;
    }

    return CheckBillResponse(
      haveActiveBill: parseBool(map['have_active_bill']),
      invoiceExternalId: map['invoice_external_id']?.toString(),
      invoiceXenditId: map['invoice_xendit_id']?.toString(),
      invoiceXenditUrl: map['invoice_xendit_url']?.toString(),
      qrExternalId: map['qr_external_id']?.toString(),
      qrXenditId: map['qr_xendit_id']?.toString(),
      qrXenditQrstring: map['qr_xendit_qrstring']?.toString(),
      qrExpireDate: map['qr_expire_date']?.toString(),
      qrAmount: parseInt(map['qr_amount']),
      invoiceAmount: parseInt(map['invoice_amount']),
      adminFee: parseInt(map['admin_fee']),
    );
  }

  Map<String, dynamic> toJson() => {
        "have_active_bill": haveActiveBill,
        "invoice_external_id": invoiceExternalId,
        "invoice_xendit_id": invoiceXenditId,
        "invoice_xendit_url": invoiceXenditUrl,
        "qr_external_id": qrExternalId,
        "qr_xendit_id": qrXenditId,
        "qr_xendit_qrstring": qrXenditQrstring,
        "qr_expire_date": qrExpireDate,
        "qr_amount": qrAmount,
        "invoice_amount": invoiceAmount,
        "admin_fee": adminFee,
      };

  CheckBillModel toEntity() {
    return CheckBillModel(
      haveActiveBill: haveActiveBill,
      invoiceExternalId: invoiceExternalId,
      invoiceXenditId: invoiceXenditId,
      invoiceXenditUrl: invoiceXenditUrl,
      qrExternalId: qrExternalId,
      qrXenditId: qrXenditId,
      qrXenditQrstring: qrXenditQrstring,
      qrExpireDate: qrExpireDate,
      qrAmount: qrAmount,
      invoiceAmount: invoiceAmount,
      adminFee: adminFee,
    );
  }

  @override
  List<Object?> get props => [
        haveActiveBill,
        invoiceExternalId,
        invoiceXenditId,
        invoiceXenditUrl,
        qrExternalId,
        qrXenditId,
        qrXenditQrstring,
        qrExpireDate,
        qrAmount,
        invoiceAmount,
        adminFee,
      ];
}
