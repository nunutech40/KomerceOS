import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextTitleInvoice extends StatelessWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final FontWeight fontWeight;

  const CustomTextTitleInvoice({super.key, 
    required this.text,
    required this.textColor,
    required this.textSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: 14,
        fontWeight: fontWeight,
      ),
    );
  }
}
