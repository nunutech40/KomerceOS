import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomOutlineButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? color;
  final Color? backGroundColor;

  const CustomOutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color = errorColor,
    this.backGroundColor = Colors.white,
  }) : super(key: key);

  @override
  _CustomOutlineButtonState createState() => _CustomOutlineButtonState();
}

class _CustomOutlineButtonState extends State<CustomOutlineButton> {
  // This height is an approximation based on the font size and vertical padding
  final double buttonHeight = 36.0; // Adjust this value as needed

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: widget.backGroundColor,
        foregroundColor: widget.color,
        side: BorderSide(color: widget.color!, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isLoading)
            SizedBox(
              width:
                  buttonHeight, // Make the width equal to the height of the button
              height: buttonHeight,
              child: const CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(lightGray),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) widget.icon!,
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
