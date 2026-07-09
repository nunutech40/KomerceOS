---
name: unit-test-repository
description: Panduan unit test untuk Repository Implementation (orkestrator data layer, Exception → Failure).
---

# Skill: Unit Test — Repository

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/core/data/repositories/xyz_repository_impl.dart
 → test/core/data/repositories/xyz_repository_impl_test.dart
```

## Filosofi
Repository adalah **"Sang Konduktor / Orkestrator"**. 
Tugasnya **HANYA** mengoordinasikan pengambilan data dari Remote dan menyimpannya di Local, serta MENGKONVERSI raw `Exception` (dari layer Data) menjadi domain `Failure` (Dartz Either: `Left`). Ia adalah benteng pelindung agar error kotor API/Local tidak merembes ke BLoC/UI.

---

## Empat Skenario Wajib (Standar Kualitas Baru)

| Skenario | Definisi |
|---|---|
| **a. Happy Path (Orkestrasi)** | Ketika Remote SUKSES, pastikan fungsi save/cache milik Local (jika ada) IKUT DIPANGGIL, lalu kembalikan tipe `Right(Entity)`.  |
| **b. Error Path (Exception to Failure)** | Saat Remote melempar Exception (`ServerException`, `DioException`, dsb), Repository **TIDAK BOLEH crash**. Secara aman harus menangkapnya dan membalikkan `Left(Failure)` yang relevan dengan deskripsi pesannya. |
| **c. Cache Fallback (Fitur Offline)** | (Khusus method get/fetch): Saat Remote GAGAL/Timeout, pastikan ia mencoba membaca data cache dari Local. Jika ada, sukses kembalikan `Right(Entity)`. |
| **d. Clean Up Safety (Khusus Logout)** | Tidak peduli apakah tembakan API ke Server SUKSES atau TIMEOUT/GAGAL, fungsi penghapusan data token dari local storage HARUS TETAP DIEKSEKUSI. Jika gagal dieksekusi, user tidak akan pernah bisa logout! |

---

## Template Lengkap

```dart
// test/core/data/repositories/xyz_repository_impl_test.dart

// =============================================================================
// PANDUAN: Repository — Sang Orkestrator 
// =============================================================================
// 1. Orkestrasi (Happy) : Remote OK → Local Save OK → Right(Entity)
// 2. Error Path         : Remote Error → tangkap → ubah jadi Left(Failure)
// 3. Cache Fallback     : Remote Error → Local Get OK → Right(Entity/Cache)
// 4. Clean Up Safety    : Remote Error Timeout → Local Clear TETAP JALAN
// =============================================================================

@GenerateMocks([XyzRemoteDataSource, SharedPref])
void main() {
  late XyzRepositoryImpl repository;
  late MockXyzRemoteDataSource mockRemote;
  late MockSharedPref mockSharedPref;

  setUp(() {
    mockRemote = MockXyzRemoteDataSource();
    mockSharedPref = MockSharedPref();
    repository = XyzRepositoryImpl(
      remoteDataSource: mockRemote,
      sharedPref: mockSharedPref,
    );
  });

  // ── Fixture ──────────────────────────────────────────────────────────────
  final tModel = XyzModel(id: 1, name: 'Test');
  const tId = '1';

  // ── 1. Orkestrasi (Fetch & Save) ──────────────────────────────────────────
  group('getData', () {

    // ----- a. HAPPY PATH (Orkestrasi) -----
    test('harus memanggil simpan ke Local jika Remote sukses (Orkestrasi)', () async {
      when(mockRemote.getData(tId)).thenAnswer((_) async => tModel);
      when(mockSharedPref.saveData(any)).thenAnswer((_) async => true);

      final result = await repository.getData(tId);

      // Pastikan konversi ke Right sukses
      expect(result, Right(tModel));
      // Verifikasi Remote dipanggil
      verify(mockRemote.getData(tId)).called(1);
      // Verifikasi Orkestrasi: fungsi simpan lokal IKUT dipanggil
      verify(mockSharedPref.saveData(tModel)).called(1);
    });

    // ----- b. ERROR PATH (Exception to Failure) -----
    test('harus return Left(ServerFailure) dan BATAL simpan lokal ketika Remote melempar Exception', () async {
       when(mockRemote.getData(tId)).thenThrow(Exception('Server error 500'));

      final result = await repository.getData(tId);

      // Exception dikonversi dengan indah menjadi Failure
      expect(result.fold((l) => expect(l, isA<ServerFailure>()), (_) => false), isTrue);
      // Orkestrasi: karena gagal tembak, TIDAK ADA PENYIMPANAN!
      verifyZeroInteractions(mockSharedPref);
    });

    // ----- c. CACHE FALLBACK (Offline Path) -----
    test('harus membaca Cache Lokal ketika HP offline (Remote melempar Timeout/ConnectionFailure)', () async {
      // API Offline/Timeout
      when(mockRemote.getData(tId)).thenThrow(
         DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionTimeout)
      );
      // TETAPI untungnya ada cache
      when(mockSharedPref.getCachedData()).thenAnswer((_) async => tModel);

      final result = await repository.getData(tId);

      expect(result, Right(tModel));
      verify(mockSharedPref.getCachedData()).called(1);
    });

    // ----- ERROR PATH EXTREME -----
    test('harus return Failure jika Remote gagal DAN Cache Lokal kosong', () async {
      when(mockRemote.getData(tId)).thenThrow(Exception('Fail'));
      when(mockSharedPref.getCachedData()).thenAnswer((_) async => null);

      final result = await repository.getData(tId);

      expect(result.isLeft(), isTrue);
    });
  });

  // ── 2. Clean Up Safety (Logout) ───────────────────────────────────────────
  group('doLogout', () {

    // ----- HAPPY PATH -----
    test('harus memanggil remote logout lalu menghapus data local saat sukses', () async {
      when(mockRemote.doLogout()).thenAnswer((_) async => true);
      when(mockSharedPref.removeDataPref()).thenAnswer((_) async => true);

      final result = await repository.doLogout();

      expect(result, const Right(true));
      verify(mockRemote.doLogout()).called(1);
      verify(mockSharedPref.removeDataPref()).called(1);
    });

    // ----- d. CLEAN UP SAFETY (PENTING!) -----
    test('AMANKAN LOGOUT LOKAL: Harus TETAP hapus preferensi local meskipun Remote menolak merespon/Timeout', () async {
      // API Server timeout atau ngadat
      when(mockRemote.doLogout()).thenThrow(Exception('Timeout server'));
      when(mockSharedPref.removeDataPref()).thenAnswer((_) async => true);

      final result = await repository.doLogout();

      // Logout dari aplikasi HARUS tetap berhasil secara local
      expect(result, const Right(true));
      // Dan PASTIKAN ini tetap tereksekusi!
      verify(mockSharedPref.removeDataPref()).called(1);
    });
  });
}
```

---

## ✅ Checklist Kualitas

- [ ] File test mirror folder lib
- [ ] `@GenerateMocks([XyzRemoteDataSource])` + local (`SharedPref`) jika ada
- [ ] **Orkestrasi**: `verify()` dipanggil untuk Storage method (`save`/`cache`) pada saat Remote sukses dipanggil dan berhasil.
- [ ] **Data Pelit (Zero Interactions)**:  Storage method `save` TIDAK DIPANGGIL sama sekali (`verifyZeroInteractions`) ketika pemanggilan data Remote gagal.
- [ ] **Exception ➔ Failure**: Validasi bahwa berbagai Exception spesifik (ConnectionTimeout, DioException, Exception lain) di-translasikan menjadi tipe `Failure` spesifik dan **bukan dire-throw/crash**.
- [ ] **Cache Fallback (jika ada cache)**: Method memanggil local read saat Remote gagal/DioException.
- [ ] **Clean Up Safety (Logout)**: Memastikan Data Clear/Hapus Token **tetap sukses diverifikasi terpanggil** *meskipun* remote api call melempar Exception! (Sangat Penting)
- [ ] Mock di-generate: `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] Lulus: `fvm flutter test test/core/data/repositories/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
