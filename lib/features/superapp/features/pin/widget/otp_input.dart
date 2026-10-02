import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:pinput/pinput.dart';

class OtpInput extends StatelessWidget {
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool isFailed;
  const OtpInput({
    Key? key,
    this.onCompleted,
    this.onChanged,
    this.validator,
    this.isFailed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 42,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        border: Border.all(
          color: isFailed ? errorColor : primaryColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: isFailed ? errorColor : primaryColor,
        width: 1.5,
      ),
    );

    final submittedPinTheme = defaultPinTheme;

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      validator: validator,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      onCompleted: onCompleted,
      length: 6,
    );
  }
}
