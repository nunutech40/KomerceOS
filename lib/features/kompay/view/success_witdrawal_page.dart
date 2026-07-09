import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';

import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/global/widgets/custom_outline_button.dart';
import '../../../core/data/shared/payload.dart';
import '../../../DI/injection.dart';
import '../../pin/view/pin_page.dart';
// 1. Define the model

// 2. Implement the SuccessWithdrawalPage
class SuccessWithdrawalPage extends StatefulWidget {
  final String? doJobfor;
  const SuccessWithdrawalPage({super.key, required this.doJobfor});

  @override
  State<SuccessWithdrawalPage> createState() => _SuccessWithdrawalPageState();
}

class _SuccessWithdrawalPageState extends State<SuccessWithdrawalPage> {
  final sharedDataService = locator<SharedDataService>();
  WithdrawalData? withdrawalData;

  @override
  void initState() {
    super.initState();
    setupData();
  }

  void setupData() {
    withdrawalData = sharedDataService.data;
    sharedDataService.clearData();
  }

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
                            text: 'Penarikan Saldo Berhasil\n',
                            style: AppTypography.semiBold20),
                        TextSpan(
                            text: 'Diajukan', style: AppTypography.semiBold20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SvgPicture.asset('assets/images/ilustrated-success.svg'),
                  const SizedBox(height: 32),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        const TextSpan(
                            text: 'Penarikan sebesar ',
                            style: AppTypography.regular16),
                        TextSpan(
                          text: CurrencyFormat.convertToIdrNum(
                              withdrawalData?.nominal ?? 0, 0),
                          style: AppTypography.bold16,
                        ),
                        const TextSpan(
                            text: ' akan segera diproses ke rekening ',
                            style: AppTypography.regular16),
                        TextSpan(
                          text: withdrawalData?.noRekening,
                          style: AppTypography.bold16,
                        ),
                        const TextSpan(
                            text: ' dalam 1x24 Jam',
                            style: AppTypography.regular16),
                      ],
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
                  text: Strings.label_see_withdrawal_history,
                  onPressed: () {
                    AppRouter.router
                        .push('${PAGES.main.screenPath}?withdrawal=${1}');
                  },
                  isActive: true,
                ),
              ),
              const SizedBox(height: 11.0),
              SizedBox(
                width: double.infinity,
                child: CustomOutlineButton(
                  text: Strings.label_complete,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
