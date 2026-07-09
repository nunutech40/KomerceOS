import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/styles.dart';

class ConfirmationDialogNeedProsessPaymentTopUp extends StatelessWidget {
  String? idTrancaction;
  String? typePayment;
  ConfirmationDialogNeedProsessPaymentTopUp(
      {super.key, required this.idTrancaction, this.typePayment});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: SvgPicture.asset("assets/images/ic-alert.svg"),
              ),
              typePayment != "withdrawal"
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Center(
                        child: Text(
                          "Maaf, ada transaksi yang belum anda selesaikan. Lanjutkan?",
                          textAlign: TextAlign.center,
                          style: AppTypography.interSemiBold14,
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Center(
                        child: Text(
                          "Maaf, permintaan withdraw Anda sedang dalam proses. Mohon tunggu.",
                          textAlign: TextAlign.center,
                          style: AppTypography.interSemiBold14,
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: typePayment != "withdrawal"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 9, bottom: 9),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 0.7),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Batal",
                                    style: AppTypography.interRegular12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                if (typePayment == "bank_transfer") {
                                  AppRouter.router.pushNamed(
                                      PAGES.bankpayment.screenName,
                                      queryParameters: {
                                        'transaction_id': [idTrancaction]
                                      });
                                } else {
                                  AppRouter.router.pushNamed(
                                      PAGES.qrispayment.screenName,
                                      queryParameters: {
                                        'transaction_id': [idTrancaction]
                                      });
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(top: 9, bottom: 9),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primaryColor),
                                child: const Center(
                                  child: Text(
                                    "Lanjutkan",
                                    style: TextStyle(color: lightGray),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 9, bottom: 9),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                          child: const Center(
                            child: Text(
                              "Mengerti",
                              style: TextStyle(color: lightGray),
                            ),
                          ),
                        ),
                      ),
              )
            ],
          ),
        ));
  }
}
