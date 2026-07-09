import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_button_small.dart';
import 'custom_outline_button_1_small.dart';

class ConfirmationDialog extends StatelessWidget {
  final void Function()? onYesPressed;
  final void Function()? onNoPressed;
  final String? textConfirmation;

  const ConfirmationDialog(
      {Key? key,
      this.onYesPressed,
      this.onNoPressed,
      this.textConfirmation = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Dialog corner radius
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set the color here
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/ic-alert.svg', // Replace with your image url
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  textConfirmation ??
                      'Anda yakin ingin keluar dari akun anda?', // Replace with your text
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: CustomOutlineButton1Small(
                        text: 'Tidak',
                        onPressed:
                            onNoPressed ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CustomButtonSmall(
                        text: 'Iya',
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
        return ConfirmationDialog(
          onYesPressed: onYesPressed,
          onNoPressed: onNoPressed,
          textConfirmation: textConfirmation,
        );
      },
    );
  }
}
