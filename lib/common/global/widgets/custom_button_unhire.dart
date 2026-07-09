import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'debounce_button.dart';

class CustomButtonUnhire extends DebouncedButton {
  final String text;
  @override
  final bool isActive;

  CustomButtonUnhire({
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
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.normal,
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.red),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.child,
          SvgPicture.asset(
            'assets/images/ic-remove-note.svg',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
