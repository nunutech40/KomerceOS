import 'package:flutter/material.dart';

/// Shared face outline for the liveness and selfie-with-KTP camera guides.
Path buildKycFaceGuidePath({
  required Offset center,
  required double width,
  required double height,
}) {
  final centerX = center.dx;
  final halfWidth = width / 2;
  final top = center.dy - height / 2;
  final bottom = center.dy + height / 2;
  return Path()
    ..moveTo(centerX, top)
    ..cubicTo(
      centerX + halfWidth * 0.72,
      top,
      centerX + halfWidth,
      top + height * 0.13,
      centerX + halfWidth,
      top + height * 0.32,
    )
    ..cubicTo(
      centerX + halfWidth,
      top + height * 0.57,
      centerX + halfWidth * 0.42,
      bottom,
      centerX,
      bottom,
    )
    ..cubicTo(
      centerX - halfWidth * 0.42,
      bottom,
      centerX - halfWidth,
      top + height * 0.57,
      centerX - halfWidth,
      top + height * 0.32,
    )
    ..cubicTo(
      centerX - halfWidth,
      top + height * 0.13,
      centerX - halfWidth * 0.72,
      top,
      centerX,
      top,
    )
    ..close();
}
