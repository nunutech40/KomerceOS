import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/global/widgets/custom_button.dart';
import '../../../common/styles.dart';

void showBottomSheetCustomNotif({
  required BuildContext context,
  required String imagePath,
  required String title,
  required String message,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.7,
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
                  imagePath, // This can be made dynamic based on your needs
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 38.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.semiBold20,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.regular14,
                ),
                const SizedBox(
                  height: 28.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(text: buttonText, onPressed: onPressed),
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
