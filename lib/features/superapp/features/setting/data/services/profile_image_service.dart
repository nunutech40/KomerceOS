import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  static const int maxFileSize = 3 * 1024 * 1024;
  final ImagePicker _picker;
  ProfileImageService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();
  Future<XFile?> pickAndCompress() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
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
