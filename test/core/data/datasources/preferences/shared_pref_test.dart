import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/constants.dart';
import 'package:komtim_partner/core/data/datasources/preferences/secure_storage_service.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';
import 'package:komtim_partner/core/data/models/login_response.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/helpers.dart';

// =============================================================================
// PANDUAN: Local DataSource — SharedPref + SecureStorageService
// =============================================================================
// Bug yang HARUS ditangkap layer ini:
//
// a. Write/Save  : verify EXACT key + EXACT value di storage yang BENAR
//    → Token ke SecureStorage (bukan SharedPref!)
//    → User data ke SharedPref (tanpa token! — security critical)
// b. Read ada    : return value tepat dari storage yang BENAR
//    → Jika hanya SharedPref yang di-clear tapi SecureStorage tidak,
//      user "logout" di UI tapi token lama masih valid → BUG KRITIS
// e. Edge        : token null → SecureStorage TIDAK disentuh (verifyNever)
// =============================================================================

void main() {
  late SharedPref sharedPref;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockPrefs = MockSharedPreferences();
    sharedPref = SharedPref(
      sharedPreferences: Future.value(mockPrefs),
      secureStorage: SecureStorageService(storage: mockSecureStorage),
    );
  });

  // ── Fixture ──────────────────────────────────────────────────────────────
  const tAccessToken = 'access_token_abc123';
  const tFcmToken = 'fcm_token_device_001';

  const tLoginResponse = LoginResponse(
    accessToken: tAccessToken,
    tokenType: 'Bearer',
    data: UserLoginData(
      id: 1,
      username: 'john_doe',
      fullName: 'John Doe',
      email: 'john@example.com',
    ),
  );

  // ── saveUserAndToken ──────────────────────────────────────────────────────
  group('saveUserAndToken', () {
    setUp(() {
      when(mockSecureStorage.write(
              key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    });

    // ----- a. WRITE — Token ke SecureStorage dengan key yang benar -----
    test('simpan access_token ke SecureStorage dengan key dan value tepat',
        () async {
      await sharedPref.saveUserAndToken(tLoginResponse);

      verify(mockSecureStorage.write(
        key: 'access_token',
        value: tAccessToken,
      )).called(1);
    });

    // ----- a. WRITE — User data ke SharedPref dengan key yang benar -----
    test('simpan user data ke SharedPref dengan key USER_AND_TOKEN', () async {
      await sharedPref.saveUserAndToken(tLoginResponse);

      verify(mockPrefs.setString(USERANDTOKEN, any)).called(1);
    });

    // ----- SECURITY CRITICAL — Token TIDAK boleh tersimpan di SharedPref -----
    test(
        '[SECURITY] token tidak tersimpan di SharedPref — hanya user data tanpa token',
        () async {
      await sharedPref.saveUserAndToken(tLoginResponse);

      // Capture JSON yang disimpan ke SharedPref
      final captured =
          verify(mockPrefs.setString(USERANDTOKEN, captureAny)).captured;
      final storedJson =
          jsonDecode(captured.first as String) as Map<String, dynamic>;

      // Token WAJIB null di SharedPref — keamanan data
      expect(storedJson['access_token'], isNull,
          reason: 'access_token tidak boleh tersimpan plain di SharedPref');
    });

    // ----- e. EDGE — Token null → SecureStorage tidak disentuh -----
    test('TIDAK menulis ke SecureStorage jika accessToken null', () async {
      const responseNoToken = LoginResponse(
        accessToken: null,
        tokenType: 'Bearer',
        data: null,
      );

      await sharedPref.saveUserAndToken(responseNoToken);

      verifyNever(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ));
    });
  });

  // ── isLoggedIn ────────────────────────────────────────────────────────────
  group('isLoggedIn', () {
    // ----- b. READ — ada token -----
    test('return true jika access_token ada dan tidak kosong', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'valid_token_abc');

      final result = await sharedPref.isLoggedIn();

      expect(result, isTrue);
      verify(mockSecureStorage.read(key: 'access_token')).called(1);
    });

    // ----- c. READ — token null -----
    test('return false jika access_token null (belum login)', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final result = await sharedPref.isLoggedIn();

      expect(result, isFalse); // tidak crash
    });

    // ----- c. READ — token string kosong -----
    test('return false jika access_token string kosong', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => '');

      final result = await sharedPref.isLoggedIn();

      expect(result, isFalse); // '' dianggap tidak login
    });
  });

  // ── getToken ──────────────────────────────────────────────────────────────
  group('getToken', () {
    // ----- b. READ — ada token -----
    test('return access_token dari SecureStorage jika ada', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => tAccessToken);

      final result = await sharedPref.getToken();

      expect(result, tAccessToken);
      verify(mockSecureStorage.read(key: 'access_token')).called(1);
    });

    // ----- c. READ — tidak ada token -----
    test('return null jika access_token tidak tersimpan', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final result = await sharedPref.getToken();

      expect(result, isNull); // tidak crash
    });
  });

  // ── getRefreshToken ───────────────────────────────────────────────────────
  group('getRefreshToken', () {
    const tRefreshToken = 'refresh_token_xyz789';

    // ----- b. READ — ada token -----
    test('return refresh_token dari SecureStorage jika ada', () async {
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => tRefreshToken);

      final result = await sharedPref.getRefreshToken();

      expect(result, tRefreshToken);
      verify(mockSecureStorage.read(key: 'refresh_token')).called(1);
    });

    // ----- c. READ — tidak ada token -----
    test('return null jika refresh_token tidak tersimpan', () async {
      when(mockSecureStorage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      final result = await sharedPref.getRefreshToken();

      expect(result, isNull); // tidak crash
    });
  });

  // ── getFcmToken ───────────────────────────────────────────────────────────
  group('getFcmToken', () {
    // ----- b. READ — ada FCM token -----
    test('return FCM token dari SharedPref jika tersimpan', () async {
      when(mockPrefs.getString(FCMTOKEN)).thenReturn(tFcmToken);

      final result = await sharedPref.getFcmToken();

      expect(result, tFcmToken);
      verify(mockPrefs.getString(FCMTOKEN)).called(1);
    });

    // ----- c. READ — FCM token belum disimpan -----
    test('return string kosong sebagai default jika FCM token null', () async {
      when(mockPrefs.getString(FCMTOKEN)).thenReturn(null);

      final result = await sharedPref.getFcmToken();

      expect(result, ''); // default value, tidak crash
    });
  });

  // ── saveFcmToken ──────────────────────────────────────────────────────────
  group('saveFcmToken', () {
    // ----- a. WRITE — FCM token ke SharedPref -----
    test('simpan FCM token ke SharedPref dengan key FCMTOKEN dan value tepat',
        () async {
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      await sharedPref.saveFcmToken(tFcmToken);

      // Verifikasi EXACT key dan value
      verify(mockPrefs.setString(FCMTOKEN, tFcmToken)).called(1);
    });
  });

  // ── removeDataPref (logout) ───────────────────────────────────────────────
  group('removeDataPref', () {
    setUp(() {
      when(mockPrefs.clear()).thenAnswer((_) async => true);
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});
    });

    // ----- d. LOGOUT — SharedPref DAN SecureStorage keduanya dibersihkan -----
    test('hapus semua data di SharedPref via clear()', () async {
      await sharedPref.removeDataPref();

      verify(mockPrefs.clear()).called(1);
    });

    // ----- d. LOGOUT — SharedPref DAN SecureStorage keduanya dibersihkan -----
    test('hapus access_token dari SecureStorage dengan key yang tepat',
        () async {
      await sharedPref.removeDataPref();

      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
    });

    // ----- d. LOGOUT — SharedPref DAN SecureStorage keduanya dibersihkan -----
    test('hapus refresh_token dari SecureStorage dengan key yang tepat',
        () async {
      await sharedPref.removeDataPref();

      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
    });

    // ----- BUG DETECTOR KRITIS — kedua token HARUS dihapus dari SecureStorage -----
    test(
        '[SECURITY] KEDUA token dihapus dari SecureStorage saat logout — tidak hanya satu',
        () async {
      await sharedPref.removeDataPref();

      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
      verify(mockPrefs.clear()).called(1);
    });
  });
}
