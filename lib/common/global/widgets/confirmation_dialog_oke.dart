import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_button_small.dart';

class ConfirmationDialogOke extends StatelessWidget {
  final void Function()? onYesPressed;

  const ConfirmationDialogOke({
    Key? key,
    this.onYesPressed,
  }) : super(key: key);

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
                    'assets/images/ic-popup-ok.svg', // Replace with your image url
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Konfirmasi lupa password telah terkirim ke email-mu. Silahkan cek kotak masuk email.', // Replace with your text
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CustomButtonSmall(
                  text: 'Oke',
                  onPressed: onYesPressed ?? () => Navigator.of(context).pop(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context,
      {void Function()? onYesPressed, void Function()? onNoPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogOke(
          onYesPressed: onYesPressed,
        );
      },
    );
  }
}
