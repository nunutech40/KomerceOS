import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomTextLabelingError extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double buttonHeight;
  final double borderRadius;

  const CustomTextLabelingError(
      {super.key,
      required this.text,
      required this.backgroundColor,
      this.buttonHeight = 20.0,
      this.borderRadius = 5.0});

  @override
  Widget build(BuildContext context) {
    Color? warna;
    // print(text);
    if (text == 'Belum Dibayar') {
      warna = warningColor;
    } else if (text == 'Kedaluwarsa') {
      warna = darkGray;
    } else {
      warna = errorColor;
    }
    return Container(
      height: buttonHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          // Added these lines
          color: warna,
          width: 2.0, // Adjust border width to your need
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: warna,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
