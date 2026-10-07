import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komtim_partner/features/superapp/features/setting/data/services/profile_image_service.dart';

void main() {
  late Directory directory;
  final service = ProfileImageService();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('profile_image_test_');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  Future<XFile> image(String name, List<int> bytes) async {
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes);
    return XFile(file.path);
  }

  test('menerima JPEG dan PNG berdasarkan signature file', () async {
    final jpeg = await image('foto.jpg', [0xFF, 0xD8, 0xFF, 0xE0]);
    final png = await image(
        'foto.png', [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    await service.validateSourceFormat(jpeg);
    await service.validateSourceFormat(png);
  });

  test('menolak GIF dan WebP walaupun nama file JPG', () async {
    final gif = await image('animasi.jpg', 'GIF89a'.codeUnits);
    final webp = await image('gambar.jpg', [
      ...'RIFF'.codeUnits,
      0,
      0,
      0,
      0,
      ...'WEBP'.codeUnits,
    ]);
    await expectLater(
      service.validateSourceFormat(gif),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      service.validateSourceFormat(webp),
      throwsA(isA<FileSystemException>()),
    );
  });
}
