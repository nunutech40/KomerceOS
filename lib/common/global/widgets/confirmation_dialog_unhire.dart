import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class ConfirmationDialogUnhire extends StatelessWidget {
  final void Function()? onYesPressed;
  final void Function()? onNoPressed;
  final String? textConfirmation;

  const ConfirmationDialogUnhire(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/ic-alert.svg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  textConfirmation ?? 'Anda yakin ingin keluar dari akun anda?',
                  style: const TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: ElevatedButton(
                        onPressed:
                            onYesPressed ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 11.0,
                            horizontal: 24.0,
                          ),
                        ),
                        child: const Text('Iya'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: ElevatedButton(
                        onPressed:
                            onNoPressed ?? () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(color: Colors.red, width: 1.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 11.0,
                            horizontal: 24.0,
                          ),
                        ),
                        child: const Text('Tidak'),
                      ),
                    ),
                  ),
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
        return ConfirmationDialogUnhire(
          onYesPressed: onYesPressed,
          onNoPressed: onNoPressed,
          textConfirmation: textConfirmation,
        );
      },
    );
  }
}
