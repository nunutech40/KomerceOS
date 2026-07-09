import 'package:flutter/material.dart';

class ButtonFilter extends StatelessWidget {
  final bool isActive;
  final void Function(String) onPressed;
  final String text;

  const ButtonFilter({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: isActive ? const Color(0xFFD6EEDD) : const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: isActive
                    ? const Color(0xFF34A853)
                    : const Color(0xFF818181)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF34A853)
                    : const Color(0xFF818181),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
