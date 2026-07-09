import 'package:flutter/material.dart';

import '../../styles.dart';
import 'debounce_button.dart';

class CustomButtonNextUnhire extends DebouncedButton {
  final String text;
  @override
  final bool isActive;

  CustomButtonNextUnhire({
    Key? key,
    required this.text,
    required VoidCallback onPressed,
    this.isActive = true,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : super(
          key: key,
          onPressed: onPressed,
          isActive: isActive,
          debounceDuration: debounceDuration,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends DebouncedButtonState {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isActive ? handleTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.isActive ? secondaryColor : inActiveGray,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
            vertical: 11.0, horizontal: 24.0),
      ),
      child: widget.child,
    );
  }
}
