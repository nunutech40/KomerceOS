import 'package:flutter/material.dart';

import '../../styles.dart';

class CustomButtonSecondary extends StatefulWidget {
  final String text;
  final bool isActive;
  final bool isLoading; // Add this line
  final VoidCallback onPressed;

  const CustomButtonSecondary({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isActive = true,
    this.isLoading = false, // Add this line
  }) : super(key: key);

  @override
  _CustomButtonSecondaryState createState() => _CustomButtonSecondaryState();
}

class _CustomButtonSecondaryState extends State<CustomButtonSecondary> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isActive ? handleTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isActive ? Colors.white : inActiveGray,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(
            color: Colors.green, // Set the stroke color to green
            width: 1.0, // Set the stroke width to 1
          ),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 11.0,
          horizontal: 24.0,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isLoading)
            const CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          Text(
            widget.text,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void handleTap() {
    widget.onPressed();
  }
}