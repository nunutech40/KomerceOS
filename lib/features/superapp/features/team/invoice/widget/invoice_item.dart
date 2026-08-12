import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/widgets/custom_text_invoice.dart';
import 'package:komtim_partner/common/styles.dart';

import '../../../../../../common/global/widgets/custom_text_labeling.dart';
import '../../../../../../common/utils/currency_format.dart';
import '../../../../../../common/utils/custom_date_format.dart';
import '../../../../../../core/domain/entities/invoices_model.dart';
import '../../../../../../core/domain/entities/transaction_history_model.dart';

class InvoiceItem extends StatelessWidget {
  final InvoicesDataModel? dataInvoice;
  final TransactionHistoryDataModel? transactionData;

  const InvoiceItem({Key? key, this.dataInvoice, this.transactionData})
      : assert(dataInvoice != null || transactionData != null),
        super(key: key);

  InvoicesDataModel mapTransactionToInvoice(TransactionHistoryDataModel data) {
    return InvoicesDataModel(
        invoiceId: data.transactionId,
        invoiceCode: data.transactionCode,
        amountTotal: data.transactionNominal,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
        transactionType: data.transactionType,
        isPaid: data.transactionStatus == "paid",
        transactionStatus: data.transactionStatus);
  }

  @override
  Widget build(BuildContext context) {
    String iconAsset;
    String title;
    bool isInvoice;

    String? getInvoiceCode(String? invoiceCode) {
      return (invoiceCode?.isEmpty ?? true) ? '-' : invoiceCode;
    }

    final invoiceData = transactionData != null
        ? mapTransactionToInvoice(transactionData!)
        : dataInvoice;

    String descInvoices(String? status) {
      switch (status) {
        case 'paid':
          return 'Berhasil';
        case 'unpaid':
          return 'Belum Dibayar';
        case 'canceled':
          return 'Dibatalkan';
        case 'expired':
          return 'Kedaluwarsa';
        default:
          return 'Gagal';
      }
    }

    String descTopUp(String? status) {
      switch (status) {
        case 'paid':
          return 'Berhasil';
        case 'unpaid':
          return 'Belum Dibayar';
        case 'canceled':
          return 'Dibatalkan';
        default:
          return 'Gagal';
      }
    }

    String descWithdrawal(String? status) {
      switch (status) {
        case 'completed':
          return 'Berhasil';
        case 'success':
          return 'Berhasil';
        case 'in_process' || 'requested':
          return 'Proses';
        case 'rejected':
          return 'Ditolak';
        case 'canceled':
          return 'Dibatalkan';
        default:
          return 'Proses';
      }
    }

    String? descInvoice() {
      if (invoiceData == null) {
        return 'Invoice data is missing';
      }

      switch (invoiceData.transactionType) {
        case 'topup':
          return descTopUp(invoiceData.transactionStatus);
        case 'withdrawal':
          return descWithdrawal(invoiceData.transactionStatus);
        case 'invoice':
          return descInvoices(invoiceData.transactionStatus);
        default:
          return invoiceData.isPaid ? 'Dibayar' : 'Belum Dibayar';
      }
    }

    switch (invoiceData?.transactionType) {
      case 'topup':
        iconAsset = 'assets/images/ic-topup.svg';
        title = 'Top Up';
        isInvoice = false;
        break;
      case 'withdrawal':
        iconAsset = 'assets/images/ic-withdraw.svg';
        title = 'Withdraw';
        isInvoice = false;
        break;
      default:
        iconAsset = 'assets/images/ic-invoice-list.svg';
        title = 'Invoice';
        isInvoice = true;
        break;
    }

    if (invoiceData?.transactionType == 'topup') {
      String? invoiceStatus = descInvoice();
      switch (invoiceStatus) {
        case 'Berhasil':
          iconAsset = 'assets/images/ic-topup.svg';
          break;
        case 'Belum Dibayar':
          iconAsset = 'assets/images/ic-topup.svg';
          break;
        case 'Dibatalkan':
          iconAsset = 'assets/images/ic-card-fail.svg';
          break;
        case 'Gagal':
          iconAsset = 'assets/images/ic-card-fail.svg';
          break;
        default:
          iconAsset = 'assets/images/ic-topup.svg';
          break;
      }
    } else if (invoiceData?.transactionType == 'withdrawal') {
      String? invoiceStatus = descInvoice();
      switch (invoiceStatus) {
        case 'Berhasil':
          iconAsset = 'assets/images/withdraw-receive.svg';
          break;
        case 'Ditolak':
          iconAsset = 'assets/images/ic-withdraw.svg';
          break;
        case 'Dibatalkan':
          iconAsset = 'assets/images/ic-withdraw.svg';
          break;
        case 'Proses':
          iconAsset = 'assets/images/withdraw-receive.svg';
          break;
        default:
          iconAsset = 'assets/images/withdraw-receive.svg';
          break;
      }
    } else {
      iconAsset = 'assets/images/ic-invoice-list.svg';
    }

    Widget customTextBasedOnInvoice() {
      String? invoiceStatus = descInvoice();

      Color backgroundColor;
      Color textColor;
      Color borderColor;

      switch (invoiceStatus) {
        case 'Dibayar':
          backgroundColor = backgroundPrimaryColor;
          textColor = primaryColor;
          borderColor = backgroundPrimaryColor;
        case 'Berhasil':
          backgroundColor = backgroundPrimaryColor;
          textColor = primaryColor;
          borderColor = backgroundPrimaryColor;

          break;
        case 'Belum Dibayar':
          backgroundColor = lightWarningColor; // You would define this color
          textColor = warningColor; // You would define this color
          borderColor = lightWarningColor;
          break;
        case 'Tidak Berhasil':
          backgroundColor = errorBackground;
          textColor = errorColor;
          borderColor = errorBackground;
          break;
        case 'Ditolak':
          backgroundColor = errorBackground;
          textColor = errorColor;
          borderColor = errorBackground;
          break;
        case 'Dibatalkan':
          backgroundColor = errorBackground;
          textColor = errorColor;
          borderColor = errorBackground;
          break;
        case 'Proses':
          backgroundColor = lightWarningColor; // You would define this color
          textColor = warningColor; // You would define this color
          borderColor = lightWarningColor;
          break;
        case 'Gagal':
          backgroundColor = errorBackground;
          textColor = errorColor;
          borderColor = errorBackground;
          break;
        case 'Kedaluwarsa':
          backgroundColor = lightGray;
          textColor = darkGray;
          borderColor = darkGray;
          break;
        default:
          backgroundColor = Colors.blue.withValues(alpha: 0.1);
          textColor = Colors.blue;
          borderColor = Colors.blue; // You would define this color
          break;
      }

      return CustomTextLabeling(
        text: invoiceStatus ?? 'Default Value',
        backgroundColor: backgroundColor,
        textColor: textColor,
        borderColor: borderColor,
      );
    }

    Widget customTextTitleInvoice(
        String titleText, double textSize, FontWeight fontWeight) {
      String? invoiceStatus = descInvoice();
      Color textColor;

      switch (invoiceData?.transactionType) {
        case 'topup':
          title = 'Top Up';
          break;
        case 'withdrawal':
          title = 'Withdraw';
          break;
        default:
          title = 'Invoice';
          break;
      }

      switch (invoiceStatus) {
        case 'Dibayar':
          textColor = primaryColor;
        case 'Berhasil':
          textColor = primaryColor;
          break;
        case 'Belum Dibayar':
          textColor = primaryColor; // You would define this color
          break;
        case 'Tidak Berhasil':
          textColor = errorColor;
        case 'Ditolak':
          textColor = errorColor;
          break;
        case 'Dibatalkan':
          textColor = errorColor;
          break;
        case 'Proses':
          textColor = primaryColor;
          break;
        case 'Kedaluwarsa':
          textColor = darkGray;
          break;
        case 'Gagal':
          textColor = errorColor;
          break;

        default:
          textColor = Colors.blue;
          break;
      }

      return CustomTextTitleInvoice(
          text: titleText,
          textColor: textColor,
          textSize: textSize,
          fontWeight: fontWeight);
    }

    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 32,
          height: 32,
        ),
        const SizedBox(
          width: 12.0,
        ),
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 5,
                      child:
                          customTextTitleInvoice(title, 14, FontWeight.w500)),
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customTextBasedOnInvoice(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      invoiceData?.transactionType == 'withdrawal' ||
                              invoiceData?.transactionType == 'topup'
                          ? CustomDateFormat.convertToDateFormat(
                              invoiceData?.createdAt ?? '')
                          : getInvoiceCode(invoiceData?.invoiceCode) ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal, // medium weight
                        fontSize:
                            invoiceData?.transactionType == 'withdrawal' ||
                                    invoiceData?.transactionType == 'topup'
                                ? 12
                                : 14,
                      ),
                    ),
                  ),
                  isInvoice
                      ? Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormat.convertToIdr(
                                    invoiceData?.amountTotal ?? 0, 0),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight:
                                      FontWeight.normal, // medium weight
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              customTextTitleInvoice(
                                  CurrencyFormat.convertToIdr(
                                      invoiceData?.amountTotal ?? 0, 0),
                                  14,
                                  FontWeight.normal),
                            ],
                          ),
                        ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                isInvoice
                    ? Expanded(
                        flex: 5,
                        child: Text(
                          CustomDateFormat.convertToDateFormat(
                              invoiceData?.createdAt ?? ''),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.normal, // medium weight
                              fontSize: 12,
                              color: darkGray),
                        ),
                      )
                    : Container(),
                isInvoice
                    ? Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            customTextTitleInvoice(
                                'Lihat Detail', 12, FontWeight.normal),
                          ],
                        ),
                      )
                    : Container(),
              ])
            ]))
      ],
    );
  }
}
