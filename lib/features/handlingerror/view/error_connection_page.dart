import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

void showErrorBottomSheet(BuildContext context, String message,
    {required VoidCallback onPressed}) {
  int height =
      PlatformDispatcher.instance.views.first.physicalSize.longestSide.toInt();

  heightBottomSheet(int heightSize) {
    if (heightSize <= 1280) {
      return 0.71;
    } else if (heightSize <= 1464) {
      return 0.63;
    } else if (heightSize >= 1464) {
      return 0.59;
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor:
            //
            //0.6, // Adjust based on your requirements
            heightBottomSheet(height),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Image.asset('assets/images/rectangle-close.png'),
                  ),
                ),
                const SizedBox(
                  height: 14.0,
                ),
                SvgPicture.asset(
                  'assets/images/ilustrated-no-connection.svg',
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 38.0),
                const Text(
                  Strings.label_no_connection,
                  textAlign: TextAlign.center,
                  style: AppTypography.semiBold20,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                  Strings.label_please_check_connection,
                  textAlign: TextAlign.center,
                  style: AppTypography.regular14,
                ),
                const SizedBox(
                  height: 28.0,
                ),
                SizedBox(
                  // This will ensure the button fills the width
                  width: double.infinity,
                  child: CustomButton(text: Strings.label_try_again, onPressed: onPressed),
                ),
                const SizedBox(
                  height: 12.0,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
