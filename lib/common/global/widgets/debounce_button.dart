import 'dart:async';
import 'package:flutter/material.dart';

class DebouncedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Duration debounceDuration;
  final ButtonStyle? buttonStyle;
  final bool isActive; // Add this line

  const DebouncedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isActive = true, // Add this line
    this.debounceDuration = const Duration(milliseconds: 500),
    this.buttonStyle,
  }) : super(key: key);

  @override
  DebouncedButtonState createState() => DebouncedButtonState();
}

class DebouncedButtonState extends State<DebouncedButton> {
  bool _isProcessing = false;
  Timer? _debounceTimer;

  void handleTap() {
    if (_isProcessing) return;

    _isProcessing = true;
    widget.onPressed();

    _debounceTimer = Timer(widget.debounceDuration, () {
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: handleTap,
      style: widget.buttonStyle, // use the custom button style
      child: widget.child,
    );
  }
}
