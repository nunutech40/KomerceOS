import 'package:flutter/material.dart';

import '../../styles.dart';
import 'debounce_button.dart';

class CustomButtonSmall extends DebouncedButton {
  final String text;

  CustomButtonSmall({
    Key? key,
    required this.text,
    required VoidCallback onPressed,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : super(
          key: key,
          onPressed: onPressed,
          debounceDuration: debounceDuration,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  _CustomButtonSmallState createState() => _CustomButtonSmallState();
}

class _CustomButtonSmallState extends DebouncedButtonState {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: handleTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 24.0),
      ),
      child: widget.child,
    );
  }
}
