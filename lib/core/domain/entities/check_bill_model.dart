import 'package:equatable/equatable.dart';

class CheckBillModel extends Equatable {
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

  const CheckBillModel({
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
