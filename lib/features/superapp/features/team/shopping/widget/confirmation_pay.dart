import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_image.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_small.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button_1_small.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

class ConfirmationPay extends StatelessWidget {
  final void Function()? onYesPressed;
  final void Function()? onNoPressed;
  final String? textConfirmation;

  const ConfirmationPay(
      {Key? key,
      this.onYesPressed,
      this.onNoPressed,
      this.textConfirmation = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: DsAppImage(
                    source: 'assets/images/superapp/team/ic_danger.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 28),
                child: Text(
                  "Konfirmasi Pembayaran",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.alwaysBlack),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 28, top: 12),
                child: Text(
                  textConfirmation ?? 'Anda yakin ingin keluar dari akun anda?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.0, color: gray737373),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: CustomOutlineButton1Small(
                        text: Strings.label_cancel,
                        onPressed:
                            onNoPressed ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CustomButtonSmall(
                        text: Strings.label_continue,
                        onPressed:
                            onYesPressed ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context,
      {void Function()? onYesPressed,
      void Function()? onNoPressed,
      String? textConfirmation}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationPay(
          onYesPressed: onYesPressed,
          onNoPressed: onNoPressed,
          textConfirmation: textConfirmation,
        );
      },
    );
  }
}
