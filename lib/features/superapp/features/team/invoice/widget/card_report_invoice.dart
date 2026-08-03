import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/custom_text_labeling_error.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

import '../../../../../../common/global/widgets/custom_text_labeling.dart';
import '../../../../../../common/utils/currency_format.dart';
import '../../../../../../common/utils/custom_date_format.dart';
import '../../../../../../core/domain/entities/invoice_detail_model.dart';
import 'dot_divider.dart';

class CardReportInvoice extends StatelessWidget {
  final InvoiceDetailModel? invoiceDetail;
  const CardReportInvoice({Key? key, required this.invoiceDetail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: invoiceDetail?.hideCosts == true
                  ? cardInvoiceHidden()
                  : cardInvoice(),
            ),
            bottomCircles(),
          ],
        ));
  }

  Widget stackDivider(Color circleColor, {bool dashed = false}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            dashed ? customDivideDash() : customDivider(),
            Positioned(
              left: -27 / 2,
              child: circleCard(circleColor),
            ),
            Positioned(
              right: -27 / 2,
              child: circleCard(circleColor),
            ),
          ],
        );
      },
    );
  }

  Widget bottomCircles() {
    return Positioned(
      bottom: -27 / 2 - 4, // Adjust this value as per your requirement
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(8, (index) => circleCard(primaryColor)),
        ),
      ),
    );
  }

  Widget customDivider() {
    return const Column(
      children: [
        SizedBox(height: 8.0),
        Divider(),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget customDivideDash() {
    return const Column(
      children: [
        SizedBox(height: 8.0),
        DotDivider(),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget circleCard(Color color) {
    return Card(
      elevation: 0.0,
      shape: const CircleBorder(),
      color: color,
      child: const SizedBox(
        width: 27.0,
        height: 27.0,
      ),
    );
  }

  Widget rowItem(String text1, String text2, {TextStyle? textStyle}) {
    textStyle ??= AppTypography.interRegular14.copyWith(color: onlyGray);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text1, style: textStyle),
        Text(text2, style: textStyle),
      ],
    );
  }

  Widget rowItemHeader(String text2, String statusTransaction) {
    String? statuspayment;
    switch (statusTransaction) {
      case 'canceled':
        statuspayment = "Dibatalkan";
        break;
      case 'paid':
        statuspayment = "Dibayar";
        break;
      case 'unpaid':
        statuspayment = "Belum Dibayar";
        break;
      case 'expired':
        statuspayment = "Kedaluwarsa";
        break;
      default:
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        statusTransaction == 'paid'
            ? CustomTextLabeling(
                // text: isPaid ? 'Dibayar' : 'Belum Dibayar',
                text: statuspayment ?? "",
                backgroundColor: Colors.white,
                textColor: primaryColor,
                borderColor: primaryColor,
                buttonHeight: 32.0,
                borderRadius: 8.0,
              )
            : CustomTextLabelingError(
                text: statuspayment ?? "",
                backgroundColor: Colors.white,
                buttonHeight: 32.0,
                borderRadius: 8.0,
              ),
        Text(text2,
            style: AppTypography.interSemiBold14.copyWith(color: onlyGray)),
      ],
    );
  }

  Widget rowItemTotal(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text1, style: AppTypography.interSemiBold18),
        Text(text2,
            style: AppTypography.interSemiBold18.copyWith(color: primaryColor)),
      ],
    );
  }

  Widget rowItemFixCost(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text1, style: AppTypography.interSemiBold16),
        Text(text2, style: AppTypography.interSemiBold16),
      ],
    );
  }

  Widget rowItemNote(String text1, String text2) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text1, style: AppTypography.interSemiBold16),
          const SizedBox(
            height: 12,
          ),
          Text(text2,
              style: AppTypography.interRegular14.copyWith(color: onlyGray)),
        ],
      ),
    );
  }

  Widget paddedRowItem(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: child,
    );
  }

  Widget cardInvoice() {
    return Column(
      children: [
        //task perlu aksi sekarang
        paddedRowItem(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rowItemHeader(
                CustomDateFormat.convertToDateFormat(
                    invoiceDetail?.createdAt ?? ''),
                invoiceDetail?.transactionStatus ?? ''),
            if (invoiceDetail?.transactionStatus == 'unpaid' &&
                invoiceDetail?.dueDate != null) ...[
              const SizedBox(height: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: lightWarningColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14.0,
                      color: warningColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Jatuh Tempo: ${CustomDateFormat.convertToDateFormatOnlyDate(invoiceDetail?.dueDate ?? '', format: 'dd MMMM yyyy')}',
                      style: AppTypography.interRegular12.copyWith(
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
        if (invoiceDetail?.transactionStatus == 'paid')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Metode Pembayaran: ${invoiceDetail?.paymentBy == 'kompay' ? 'KomPay' : invoiceDetail?.paymentBy == 'transfer_bank' ? 'Transfer Bank' : invoiceDetail?.paymentBy ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),

        customDivider(),
        const SizedBox(
          height: 18.0,
        ),
        paddedRowItem(rowItem(
          Strings.label_admin_cost,
          CurrencyFormat.convertToIdr(invoiceDetail?.adminFeeAmount ?? 0, 0),
        )),
        paddedRowItem(rowItem(
            Strings.label_tax_pph23,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0) ==
                    "Rp0"
                ? CurrencyFormat.convertToIdrNum(
                    invoiceDetail?.taxAmount ?? 0, 0)
                : " - ${CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0)}")),
        paddedRowItem(rowItem(Strings.label_tax_ppn11,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.ppnAmount ?? 0, 0))),
        stackDivider(primaryColor, dashed: true),
        paddedRowItem(rowItem(Strings.label_sub_total,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.subTotal1 ?? 0, 0),
            textStyle: AppTypography.interSemiBold16)),
        paddedRowItem(rowItem(
            Strings.label_insentive_talent,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.talentSalaryAmount ?? 0, 0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: customDivideDash(),
        ),
        paddedRowItem(rowItem(Strings.label_sub_total,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.subTotal2 ?? 0, 0),
            textStyle: AppTypography.interSemiBold16)),
        paddedRowItem(rowItem(
            Strings.label_aplication_service,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.appsServiceAmount ?? 0, 0))),
        paddedRowItem(rowItem(
            Strings.label_additioanal_cost,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.additionalCost ?? 0, 0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: customDivideDash(),
        ),
        paddedRowItem(rowItemTotal(Strings.label_total,
            CurrencyFormat.convertToIdr(invoiceDetail?.amountTotal ?? 0, 0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: customDivideDash(),
        ),
        paddedRowItem(rowItemNote(
          Strings.label_explanation,
          invoiceDetail?.notes ?? "",
        )),
        const SizedBox(height: 32.0),
      ],
    );
  }

  Widget cardInvoiceHidden() {
    int adminFeeAmount = invoiceDetail?.adminFeeAmount?.toInt() ?? 0;
    int insentifTalent = invoiceDetail?.talentSalaryAmount?.toInt() ?? 0;
    int fixCost = adminFeeAmount + insentifTalent;
    return Column(
      children: [
        //task perlu aksi sekarang
        paddedRowItem(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rowItemHeader(
                CustomDateFormat.convertToDateFormat(
                    invoiceDetail?.createdAt ?? ''),
                invoiceDetail?.transactionStatus ?? ''),
            if (invoiceDetail?.transactionStatus == 'unpaid' &&
                invoiceDetail?.expiredAt != null) ...[
              const SizedBox(height: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: lightWarningColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14.0,
                      color: warningColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Jatuh Tempo: ${CustomDateFormat.convertToDateFormat(invoiceDetail?.expiredAt ?? '', format: 'dd MMMM yyyy')}',
                      style: AppTypography.interRegular12.copyWith(
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
        customDivider(),
        const SizedBox(
          height: 18.0,
        ),
        paddedRowItem(rowItemFixCost(
            Strings.label_fix_cost, CurrencyFormat.convertToIdr(fixCost, 0))),
        paddedRowItem(rowItem(
            Strings.label_tax_pph23,
            CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0) ==
                    "Rp0"
                ? CurrencyFormat.convertToIdrNum(
                    invoiceDetail?.taxAmount ?? 0, 0)
                : " - ${CurrencyFormat.convertToIdrNum(invoiceDetail?.taxAmount ?? 0, 0)}")),
        stackDivider(primaryColor, dashed: true),
        paddedRowItem(rowItem(
            Strings.label_aplication_service,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.appsServiceAmount ?? 0, 0))),
        paddedRowItem(rowItem(
            Strings.label_additioanal_cost,
            CurrencyFormat.convertToIdr(
                invoiceDetail?.additionalCost ?? 0, 0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: customDivideDash(),
        ),
        paddedRowItem(rowItemTotal(Strings.label_total,
            CurrencyFormat.convertToIdr(invoiceDetail?.amountTotal ?? 0, 0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: customDivideDash(),
        ),
        paddedRowItem(rowItemNote(
          Strings.label_explanation,
          invoiceDetail?.notes ?? "",
        )),
        const SizedBox(height: 32.0),
      ],
    );
  }
}
