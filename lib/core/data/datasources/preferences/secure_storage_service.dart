import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan untuk menyimpan data sensitif (seperti token akses) secara aman.
///
/// Menggunakan [FlutterSecureStorage] untuk menyimpan data di Keystore (Android)
/// atau Keychain (iOS) yang terenkripsi.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Kunci untuk penyimpanan
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _pinOtpKey = 'otp_challenge_pin';
  static const String _bankOtpKey = 'otp_challenge_rekening';

  String _otpKey(String purpose) => switch (purpose) {
        'pin' => _pinOtpKey,
        'rekening' => _bankOtpKey,
        _ => throw ArgumentError.value(purpose, 'purpose'),
      };

  Future<void> saveOtpChallenge(String purpose, Map<String, String> value) =>
      _storage.write(key: _otpKey(purpose), value: jsonEncode(value));

  Future<Map<String, String>?> readOtpChallenge(String purpose) async {
    final stored = await _storage.read(key: _otpKey(purpose));
    if (stored == null) return null;
    try {
      final parsed = jsonDecode(stored);
      if (parsed is! Map) return null;
      return parsed.map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString()));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearOtpChallenge(String purpose) =>
      _storage.delete(key: _otpKey(purpose));

  Future<void> clearAllOtpChallenges() async {
    await _storage.delete(key: _pinOtpKey);
    await _storage.delete(key: _bankOtpKey);
  }

  /// Menyimpan Access Token dan Refresh Token secara aman.
  ///
  /// [accessToken] Token akses pengguna.
  /// [refreshToken] Token refresh untuk memperbarui sesi.
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Mengambil Access Token dari penyimpanan aman.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Mengambil Refresh Token dari penyimpanan aman.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Menghapus semua token (Access & Refresh) dari penyimpanan.
  ///
  /// Biasanya dipanggil saat pengguna logout.
  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Menghapus semua data yang tersimpan di secure storage.
  ///
  /// Gunakan dengan hati-hati.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
