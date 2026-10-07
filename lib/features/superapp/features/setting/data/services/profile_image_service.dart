import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  static const int maxFileSize = 3 * 1024 * 1024;
  final ImagePicker _picker;
  ProfileImageService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  /// Periksa berkas sumber, bukan hasil kompresi, agar GIF/WebP tidak lolos
  /// hanya karena keduanya dapat dikonversi menjadi JPEG.
  Future<void> validateSourceFormat(XFile image) async {
    final file = await File(image.path).open();
    try {
      final bytes = await file.read(8);
      final isJpeg = bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF;
      final isPng = bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A;
      if (!isJpeg && !isPng) {
        throw const FileSystemException(
            'Format foto tidak didukung. Gunakan JPG atau PNG.');
      }
    } finally {
      await file.close();
    }
  }

  Future<XFile?> pickAndCompress() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    await validateSourceFormat(picked);
    final target =
        '${Directory.systemTemp.path}/komerce_profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      target,
      minWidth: 800,
      minHeight: 800,
      quality: 80,
      keepExif: false,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) {
      throw const FileSystemException('Gagal mengompres gambar');
    }
    if (await compressed.length() > maxFileSize) {
      await File(compressed.path).delete();
      throw const FileSystemException('Ukuran gambar melebihi 3 MB');
    }
    return compressed;
  }
}
