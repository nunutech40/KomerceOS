import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class RateTalentNotifPage extends StatefulWidget {
  final String xenditUrl;
  final int invoiceId;
  final String invoiceCode;
  const RateTalentNotifPage(
      {Key? key, required this.xenditUrl, required this.invoiceId, required this.invoiceCode})
      : super(key: key);

  @override
  State<RateTalentNotifPage> createState() => _RateTalentNotifPageState();
}

class _RateTalentNotifPageState extends State<RateTalentNotifPage> {
  @override
  void initState() {
    super.initState();
    context.read<InvoiceDetailBloc>().add(CopyInvoiceDetail(widget.xenditUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.label_evaluation_talent,
            style: AppTypography.interSemiBold16),
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
          onPressed: () {
            AppRouter.router.pop();
          },
        ),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: ClipRRect(
                child: SvgPicture.asset(
                  'assets/images/ilustrate-star.svg', // Replace with your image url
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              Strings.dialog_before_rating_1,
              style: AppTypography.semiBold20,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Text(
              Strings.dialog_before_rating_2,
              style: AppTypography.regular14,
              textAlign: TextAlign.center,
            )
          ],
        ),
      )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomButton(
            text: Strings.label_continue,
            onPressed: () {
              AppRouter.router.pushNamed(
                PAGES.rateTalentCheckPage.screenName,
                queryParameters: {
                  'xenditUrl': widget.xenditUrl,
                  'invoiceId': [((widget.invoiceId).toString())],
                  'invoiceCode': widget.invoiceCode,
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
