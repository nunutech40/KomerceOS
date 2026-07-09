---
name: unit-test-datasource-local
description: Panduan unit test untuk Local DataSource (SharedPref + SecureStorage). Mock library penyimpanan, bukan implementasi.
---

# Skill: Unit Test — Local DataSource

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/core/data/datasources/preferences/shared_pref.dart
 → test/core/data/datasources/preferences/shared_pref_test.dart
```

## Filosofi
Local DataSource menyimpan/membaca data persisten (offline). Di project ini ada dua layer:
- **`SecureStorageService`** → Token (terenkripsi via FlutterSecureStorage)
- **`SharedPref`** → Cache profil, FCM token, data ringan (via SharedPreferences)

Mock **library-nya** (`FlutterSecureStorage`, `SharedPreferences`), bukan implementasinya.

---

## Lima Skenario Wajib

| Path | Skenario | Ekspektasi |
|---|---|---|
| **a. Write (Save)** | Data disimpan | Verifikasi **key yang tepat** + **value yang tepat** — `verify(mock.write(key: 'access_token', value: 'abc'))` |
| **b. Read — ada data** | Data tersimpan sebelumnya | Return value yang tepat, cek field |
| **c. Read — kosong/null** | Tidak ada data tersimpan | Return default value, **tidak crash** |
| **d. Clear/Logout** | `removeDataPref` dipanggil | `prefs.clear()` **DAN** `secureStorage.deleteTokens()` — keduanya wajib diverifikasi |
| **e. Edge — data parsial** | Data tersimpan sebagian (misal token ada, profil tidak) | Return null/default yang tepat, tidak throws |

---

## Aturan Kualitas

### ✅ Verifikasi key dan value yang EXACT saat write
```dart
// BAIK: cek key dan value persis
verify(mockSecureStorage.write(
  key: 'access_token',
  value: 'access_token_abc',
)).called(1);
verify(mockSecureStorage.write(
  key: 'refresh_token',
  value: 'refresh_token_xyz',
)).called(1);

// BURUK: tidak tahu key apa yang dipakai
verify(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
```

### ✅ Verifikasi KEDUANYA saat logout
```dart
// BAIK: kedua storage dibersihkan
verify(mockPrefs.clear()).called(1);
verify(mockSecureStorage.delete(key: 'access_token')).called(1);
verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);

// BURUK: hanya cek satu
verify(mockPrefs.clear());
// lupa cek secureStorage.delete → token mungkin tidak terhapus!
```

### ✅ Verifikasi read dengan data ada DAN tidak ada
```dart
// BAIK: cover keduanya
test('return token jika ada', () async {
  when(mockSecureStorage.read(key: 'access_token'))
      .thenAnswer((_) async => 'valid_token');
  expect(await sharedPref.getToken(), 'valid_token');
});

test('return null jika token tidak ada', () async {
  when(mockSecureStorage.read(key: 'access_token'))
      .thenAnswer((_) async => null);
  expect(await sharedPref.getToken(), isNull); // tidak crash
});
```

---

## Template Lengkap

```dart
// test/core/data/datasources/preferences/shared_pref_test.dart

// =============================================================================
// PANDUAN: Local DataSource — SharedPref + SecureStorageService
// =============================================================================
// a. Write/Save  : verify exact key + exact value
// b. Read ada    : return value tepat, cek field
// c. Read kosong : return null/default, tidak crash
// d. Logout      : prefs.clear() DAN kedua secureStorage.delete() — keduanya!
// e. Edge         : data parsial, field missing → tidak throws
// =============================================================================

@GenerateMocks([FlutterSecureStorage, SharedPreferences])
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
  const tAccessToken = 'access_token_abc';
  const tRefreshToken = 'refresh_token_xyz';

  final tLoginResponse = LoginResponse(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
    tokenType: 'Bearer',
    data: UserLoginData(
      id: 1,
      partnerId: 10,
      partnerNo: 'P-001',
      username: 'john_doe',
      fullname: 'John Doe',
      email: 'john@example.com',
    ),
  );

  // ── a. Write — saveUserAndToken ───────────────────────────────────────────
  group('saveUserAndToken', () {

    // ----- HAPPY PATH -----
    test('simpan token ke SecureStorage dengan key yang benar', () async {
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      await sharedPref.saveUserAndToken(tLoginResponse);

      // Verifikasi EXACT key dan value
      verify(mockSecureStorage.write(key: 'access_token', value: tAccessToken)).called(1);
      verify(mockSecureStorage.write(key: 'refresh_token', value: tRefreshToken)).called(1);
      // Verifikasi SharedPref juga dipanggil
      verify(mockPrefs.setString(any, any)).called(1);
    });

    // ----- EDGE PATH -----
    test('tidak simpan token ke SecureStorage jika accessToken null', () async {
      final responseNoToken = LoginResponse(
        accessToken: null,
        refreshToken: null,
        tokenType: 'Bearer',
        data: null,
      );
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      await sharedPref.saveUserAndToken(responseNoToken);

      verifyNever(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ));
    });
  });

  // ── b & c. Read — isLoggedIn ──────────────────────────────────────────────
  group('isLoggedIn', () {

    // ----- b. READ — ada data -----
    test('return true jika access token ada dan tidak kosong', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => 'valid_token');

      expect(await sharedPref.isLoggedIn(), isTrue);
    });

    // ----- c. READ — kosong/null -----
    test('return false jika access token null', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      expect(await sharedPref.isLoggedIn(), isFalse);
    });

    test('return false jika access token string kosong', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => '');

      expect(await sharedPref.isLoggedIn(), isFalse);
    });
  });

  // ── b & c. Read — getFcmToken ─────────────────────────────────────────────
  group('getFcmToken', () {

    test('return fcm token jika tersimpan', () async {
      when(mockPrefs.getString(any)).thenReturn('fcm_token_123');

      final result = await sharedPref.getFcmToken();

      expect(result, 'fcm_token_123');
    });

    test('return string kosong jika FCM token belum tersimpan', () async {
      when(mockPrefs.getString(any)).thenReturn(null);

      final result = await sharedPref.getFcmToken();

      expect(result, ''); // default value, tidak crash
    });
  });

  // ── d. Clear — removeDataPref (logout) ───────────────────────────────────
  group('removeDataPref', () {

    // ----- HAPPY PATH -----
    test('hapus SharedPreferences DAN kedua token di SecureStorage', () async {
      when(mockPrefs.clear()).thenAnswer((_) async => true);
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      await sharedPref.removeDataPref();

      // Keduanya WAJIB dipanggil
      verify(mockPrefs.clear()).called(1);
      verify(mockSecureStorage.delete(key: 'access_token')).called(1);
      verify(mockSecureStorage.delete(key: 'refresh_token')).called(1);
    });
  });

  // ── b & c. Read — getToken ────────────────────────────────────────────────
  group('getToken', () {

    test('return access token dari SecureStorage jika ada', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => tAccessToken);

      final result = await sharedPref.getToken();

      expect(result, tAccessToken);
    });

    test('return null jika token belum tersimpan', () async {
      when(mockSecureStorage.read(key: 'access_token'))
          .thenAnswer((_) async => null);

      final result = await sharedPref.getToken();

      expect(result, isNull); // tidak crash
    });
  });
}
```

---

## ✅ Checklist Kualitas

- [ ] File test mirror folder lib
- [ ] `@GenerateMocks([FlutterSecureStorage, SharedPreferences])`
- [ ] **Write**: `verify(mock.write(key: 'exact_key', value: 'exact_value')).called(1)` — exact, bukan `anyNamed`
- [ ] **Read (ada data)**: return value tepat + cek field
- [ ] **Read (kosong/null)**: return default value + tidak crash (tidak throws)
- [ ] **Logout**: `verify(prefs.clear())` **DAN** kedua `verify(secureStorage.delete(key: ...))` — keduanya!
- [ ] **Edge**: token null → `verifyNever(secureStorage.write(...))` — pastikan tidak tersimpan
- [ ] Mock di-generate: `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] Lulus: `fvm flutter test test/core/data/datasources/preferences/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
