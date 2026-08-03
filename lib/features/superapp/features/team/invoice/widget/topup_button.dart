import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class TopUpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TopUpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: primaryColor),
        foregroundColor:primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 63, vertical: 9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: const Text('Top Up Saldo'),
    );
  }
}
