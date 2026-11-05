import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_crop_geometry.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_capture_area.dart';
import 'package:path_provider/path_provider.dart';

/// Produces the KTP-only photo shown to the user and sent to OCR.
abstract final class KtpPhotoCropper {
  static Future<String> cropToTemporaryFile(
    String sourcePath,
    KtpCaptureArea area,
  ) async {
    final bytes = await File(sourcePath).readAsBytes();
    final croppedBytes = await compute(_cropKtp, (bytes, area));
    final directory = await getTemporaryDirectory();
    final output = File(
      '${directory.path}/ktp_crop_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    try {
      await output.writeAsBytes(croppedBytes, flush: true);
      return output.path;
    } catch (_) {
      if (await output.exists()) await output.delete();
      rethrow;
    }
  }
}

Uint8List _cropKtp((Uint8List, KtpCaptureArea) input) {
  final (bytes, area) = input;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Invalid KTP image');
  final source = img.bakeOrientation(decoded);
  final region = ktpCropRegion(
    imageWidth: source.width,
    imageHeight: source.height,
    area: area,
  );
  final cropped = img.copyCrop(
    source,
    x: region.x,
    y: region.y,
    width: region.width,
    height: region.height,
  );
  return img.encodeJpg(cropped, quality: 95);
}
