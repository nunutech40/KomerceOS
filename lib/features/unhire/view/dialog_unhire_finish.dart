import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/string.dart';

class DialogUnhireFinish extends StatefulWidget {
  const DialogUnhireFinish({super.key});

  @override
  State<DialogUnhireFinish> createState() => _DialogUnhireFinishState();
}

class _DialogUnhireFinishState extends State<DialogUnhireFinish> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppRouter.router.go(PAGES.main.screenPath);
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 116.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  Strings.dialog_unhire_telent_1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  Strings.dialog_unhire_telent_2,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/images/ic_disapointed.svg',
                  width: 195,
                  height: 237,
                ),
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    Strings.dialog_unhire_telent_3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: Strings.label_complete,
                      onPressed: () {
                        AppRouter.router.go(PAGES.main.screenPath);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
