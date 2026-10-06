import 'package:flutter/material.dart';

import 'package:komtim_partner/features/superapp/features/pin/view/pop_up_page.dart';

mixin PopUpPin {
  void showPopUpNotYetSetPin(
    BuildContext context,
    String title,
    String message,
    String imagePath,
    String buttonText, {
    VoidCallback? onButtonPressed,
  }) {
    showBottomSheetCustomNotif(
        context: context,
        imagePath: imagePath,
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onButtonPressed ?? () {});
  }
}
