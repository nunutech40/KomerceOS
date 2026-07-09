import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextLabeling extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor; // Added this
  final double buttonHeight;
  final double borderRadius;

  const CustomTextLabeling(
      {super.key, required this.text,
      required this.backgroundColor,
      required this.textColor,
      this.borderColor = Colors.black, // And this, defaults to black
      this.buttonHeight = 20.0,
      this.borderRadius = 5.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          // Added these lines
          color: borderColor,
          width: 2.0, // Adjust border width to your need
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
