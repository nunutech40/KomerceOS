import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button.dart';
import 'package:komtim_partner/common/styles.dart';

class SuccessPaymentKompayPage extends StatefulWidget {
  final String? invoiceId;
  final String? status;
  const SuccessPaymentKompayPage({super.key, required this.invoiceId, required this.status});

  @override
  State<SuccessPaymentKompayPage> createState() =>
      _SuccessPaymentKompyPageState();
}

class _SuccessPaymentKompyPageState extends State<SuccessPaymentKompayPage> {
  @override
  void initState() {
    super.initState();
    setupData();
  }

  void setupData() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return true;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'Pembayaran Berhasil',
                            style: AppTypography.semiBold20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SvgPicture.asset('assets/images/ilustrated-success.svg'),
                  const SizedBox(height: 32),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Ringkasan Pembayaran',
                  onPressed: () {
                    AppRouter.router.pushNamed(
                      PAGES.invoiceReportSummary.screenName,
                      queryParameters: {
                        'invoiceCode': widget.invoiceId,
                        'statusAccount': widget.status,
                        'from': 'payment'
                      },
                    );
                  },
                  isActive: true,
                ),
              ),
              const SizedBox(height: 11.0),
              SizedBox(
                width: double.infinity,
                child: CustomOutlineButton(
                  text: 'Lihat Riwayat Pembayaran',
                  onPressed: () {
                    AppRouter.router
                        .push('${PAGES.main.screenPath}?withdrawal=${1}');
                  },
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 69.0),
            ],
          ),
        ),
      ),
    );
  }
}
