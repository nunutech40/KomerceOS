import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Downloads a KYC photo from the signed storage URL in `latest-history`.
///
/// The URLs are signed Google Cloud Storage links that expire after ~59
/// seconds (dev, 18 Nov 2026), so the page fetches them immediately and keeps
/// a local copy for preview and OCR. A plain [HttpClient] is used on purpose:
/// `DioClient` adds the API base URL and auth header, which a signed URL must
/// not receive.
abstract final class KycServerPhotoDownloader {
  static const _timeout = Duration(seconds: 20);

  /// Returns the downloaded file, or null when the photo cannot be fetched
  /// (expired link, network error, empty body).
  static Future<File?> tryDownload(String url, {required String name}) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    File? file;
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        debugPrint('[KYC] Foto server $name HTTP ${response.statusCode}');
        return null;
      }
      final directory = await getTemporaryDirectory();
      file = File(
          '${directory.path}/kyc_server_${name}_${DateTime.now().microsecondsSinceEpoch}.jpg');
      final sink = file.openWrite();
      await response.timeout(_timeout).pipe(sink);
      if (await file.length() == 0) {
        await file.delete();
        return null;
      }
      return file;
    } catch (error) {
      debugPrint('[KYC] Foto server $name gagal diunduh: $error');
      if (file != null && await file.exists()) await file.delete();
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
