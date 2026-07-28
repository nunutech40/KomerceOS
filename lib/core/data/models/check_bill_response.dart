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

  factory CheckBillResponse.fromJson(Map<String, dynamic> json) {
    return CheckBillResponse(
      haveActiveBill: json['have_active_bill'],
      invoiceExternalId: json['invoice_external_id'],
      invoiceXenditId: json['invoice_xendit_id'],
      invoiceXenditUrl: json['invoice_xendit_url'],
      qrExternalId: json['qr_external_id'],
      qrXenditId: json['qr_xendit_id'],
      qrXenditQrstring: json['qr_xendit_qrstring'],
      qrExpireDate: json['qr_expire_date'],
      qrAmount: json['qr_amount'],
      invoiceAmount: json['invoice_amount'],
      adminFee: json['admin_fee'],
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
