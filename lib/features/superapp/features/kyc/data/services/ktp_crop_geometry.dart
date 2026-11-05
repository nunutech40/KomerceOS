import 'dart:math' as math;

import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_capture_area.dart';

class KtpCropRegion {
  const KtpCropRegion(this.x, this.y, this.width, this.height);

  final int x;
  final int y;
  final int width;
  final int height;
}

/// Inverse of the centered BoxFit.cover transform used by the camera preview.
/// Adds a small margin so card edges near the guide are not clipped.
KtpCropRegion ktpCropRegion({
  required int imageWidth,
  required int imageHeight,
  required KtpCaptureArea area,
}) {
  if (imageWidth <= 0 ||
      imageHeight <= 0 ||
      area.viewportWidth <= 0 ||
      area.viewportHeight <= 0 ||
      area.width <= 0 ||
      area.height <= 0) {
    throw const FormatException('Invalid KTP crop geometry');
  }

  final scale = math.max(
    area.viewportWidth / imageWidth,
    area.viewportHeight / imageHeight,
  );
  final offsetX = (imageWidth * scale - area.viewportWidth) / 2;
  final offsetY = (imageHeight * scale - area.viewportHeight) / 2;
  final marginX = area.width * .08;
  final marginY = area.height * .08;
  final left = ((area.left - marginX + offsetX) / scale)
      .floor()
      .clamp(0, imageWidth - 1);
  final top = ((area.top - marginY + offsetY) / scale)
      .floor()
      .clamp(0, imageHeight - 1);
  final right = ((area.left + area.width + marginX + offsetX) / scale)
      .ceil()
      .clamp(left + 1, imageWidth);
  final bottom = ((area.top + area.height + marginY + offsetY) / scale)
      .ceil()
      .clamp(top + 1, imageHeight);
  return KtpCropRegion(left, top, right - left, bottom - top);
}
