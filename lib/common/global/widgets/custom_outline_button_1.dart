import 'package:flutter/material.dart';
import 'debounce_button.dart';

class CustomOutlineButton1 extends DebouncedButton {
  final String text;

  CustomOutlineButton1({
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 11.0, horizontal: 24.0),
          ),
        );
}
