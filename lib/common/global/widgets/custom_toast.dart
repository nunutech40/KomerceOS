import 'package:flutter/material.dart';

class CustomToast extends StatelessWidget {
  final String message;

  const CustomToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0x99C2C2C2),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF333333)),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100.0,
      left: MediaQuery.of(context).size.width * 0.5 - 100.0,
      child: Material(
        color: Colors.transparent,
        child: CustomToast(message: message),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
