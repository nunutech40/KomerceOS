import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  final ImagePicker _picker;
  ProfileImageService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();
  Future<XFile?> pickAndCompress() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    final target =
        '${Directory.systemTemp.path}/komerce_profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return await FlutterImageCompress.compressAndGetFile(picked.path, target,
            minWidth: 1200,
            minHeight: 1200,
            quality: 80,
            format: CompressFormat.jpeg) ??
        picked;
  }
}
