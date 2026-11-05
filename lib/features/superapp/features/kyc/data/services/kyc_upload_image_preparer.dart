import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps the camera original for preview/OCR and creates a bounded JPEG copy
/// only for the multipart upload.
abstract final class KycUploadImagePreparer {
  static const maxBytes = 1024 * 1024;

  static Future<File> prepare(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists() || await source.length() == 0) {
      throw const FileSystemException('Foto KYC tidak tersedia');
    }
    final directory = await getTemporaryDirectory();
    File? last;
    for (final (quality, width) in [(85, 1600), (70, 1400), (55, 1200)]) {
      final target =
          '${directory.path}/kyc_upload_${DateTime.now().microsecondsSinceEpoch}_$quality.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        target,
        minWidth: width,
        minHeight: width,
        quality: quality,
        keepExif: false,
        format: CompressFormat.jpeg,
      );
      if (result == null) {
        throw const FileSystemException('Gagal mengompres foto KYC');
      }
      final file = File(result.path);
      if (last != null) await last.delete();
      last = file;
      final size = await file.length();
      if (size > 0 && size <= maxBytes) return file;
    }
    if (last != null) await last.delete();
    throw const FileSystemException('Foto KYC melebihi 1 MB setelah kompresi');
  }
}
