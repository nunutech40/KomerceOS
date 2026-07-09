---
name: unit-test-usecase
description: Panduan unit test untuk UseCase (Domain Layer). Menguji integritas forwarder dan verify contract.
---

# Skill: Unit Test — Use Case (Domain Layer)

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/core/domain/usecases/get_xyz_use_case.dart
 → test/core/domain/usecases/get_xyz_use_case_test.dart
```

## Filosofi
Walaupun sebagian besar Use Case secara logic hanya menjadi sebuah **"Jembatan Penerus" (Forwarder)** menuju layer Repository. Kita **TETAP HARUS menguji konsistensinya (Return Integrity) di setiap celah kemungkinannya**. 
Fokus utamanya adalah menjamin bahwa Repository dipanggil tepat satu kali dengan parameter yang akurat, tanpa adanya manipulasi side-call, dan meneruskan `Left` atau `Right` secara murni tanpa *crash/bocor*.

---

## Empat Skenario Wajib (Standar Kualitas)

| Skenario | Definisi | Fokus Code |
|---|---|---|
| **1. Contract / Zero Interactions** | Pastikan repository dipanggil **Tepat dengan Method yang Sama dan Param yg Sama**, dan dipanggil **tepat HANYA 1x**, dilarang ada interaksi tersembunyi ke fungsi lain di repository yang sama. | `verify(…).called(1)` dan `verifyNoMoreInteractions(mock)` |
| **2. Happy Path (Forwarding)** | Use Case wajib menerima balasan `Right(Entity)` dari Repository lalu meneruskannya murni (utuh) ke layer pemanggilnya tanpa terlewat satupun state. | `expect(result, Right(tEntity))` |
| **3. Error Path (Forwarding)** | Use Case wajib mampu menahan gempuran peluru `Left(Failure)` yang dilemparkan oleh Repository, dan di-*forward* ke layer Bloc/Controller secara terstruktur. | `expect(result, Left(tFailure))` |
| **4. Chain Path** *(Jika ada)* | Jika sebuah Use case memanggil 2 usecase/repo secara linear (misal Login sukses ➔ ambil Profile) maka pastikan Usecase ke-2 dieksekusi atau Use case ke-2 digagalkan ketika Call pertama gagal. | `verify(mockB).called(1)` / `verifyNever(mockB)` |

---

## Template Lengkap

```dart
// test/core/domain/usecases/get_xyz_use_case_test.dart

// =============================================================================
// PANDUAN UNIT TEST UNTUK USE CASE (DOMAIN LAYER)
// =============================================================================
// 1. Contract Match : Harus call repository di parameter yang benar `.called(1)`
// 2. No leakage     : Jangan ada interaksi diam-diam `verifyNoMoreInteractions`
// 3. Happy Path     : Right(Entity) tidak diubah sedikitpun
// 4. Error Path     : Left(Failure) diteruskan mentah-mentah ke pemanggilnya
// =============================================================================

@GenerateMocks([XyzRepository])
void main() {
  late GetXyzUseCase usecase;
  late MockXyzRepository mockRepository;

  setUp(() {
    mockRepository = MockXyzRepository();
    usecase = GetXyzUseCase(mockRepository);
  });

  // ── Fixture ──────────────────────────────────────────────────────────────
  const tId = '1';
  final tEntity = XyzModel(id: 1, name: 'Test');
  final tFailure = ServerFailure(message: 'Error tidak terduga');

  group('GetXyz Use Case', () {
  
    // ── HAPPY PATH ─────────────────────────────────────────────────────────
    test('harus meneruskan panggil method ke repository dan mengembalikan Right(XyzEntity) dengan utuh', () async {
      // Arrange
      when(mockRepository.getData(tId))
          .thenAnswer((_) async => Right(tEntity));

      // Act
      final result = await usecase.call(tId);

      // Assert
      expect(result, Right(tEntity)); // Murni dilempar utuh
      // Kontrak 1X pemanggilan dengan parameter tId yang akurat
      verify(mockRepository.getData(tId)).called(1); 
      // Amankan dari pemanggilan tersembunyi!
      verifyNoMoreInteractions(mockRepository); 
    });

    // ── ERROR PATH ─────────────────────────────────────────────────────────
    test('harus meneruskan panggilan catch ke repository dan melempar utuh peluru Left(Failure) ke atas', () async {
      // Arrange
      when(mockRepository.getData(tId))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase.call(tId);

      // Assert
      expect(result, Left(tFailure));
      // Tetap terverifikasi terpanggil 1x param tepat (karna error dilempar oleh Repo, Usecase tak bersalah)
      verify(mockRepository.getData(tId)).called(1);
    });

    // ── CHAIN PATH (Jika Usecase A memanggil Repo A dan Usecase B) ─────────
    /*
    test('harus TIDAK memanggil UseCase Profile jika Login gagal ditengah jalan', () async {
        // Arrange
        when(mockRepository.login(any)).thenAnswer((_) async => Left(tFailure));

        // Act 
        await usecaseDuaLangkah(LoginParams);

        // Assert
        // Verifikasi login berjalan
        verify(mockRepository.login(any)).called(1);
        // Pastikan getProfile dilarang di execute
        verifyNever(mockUseCaseProfile.call()); 
    });
    */
  });
}
```

---

## ✅ Checklist Kualitas (Quality Gates)

- [ ] File test mirror folder lib (`test/core/domain/usecases/`)
- [ ] Tersedia `@GenerateMocks([XyzRepository])` (Atau semua jajaran dependensi di konstruktor Usecase tersebut)
- [ ] **Contract Verification**: Gunakan `.called(1)` untuk mengunci interaksi ke MockRepo hanya berjumlah persis 1 tembakan.
- [ ] **Leakage Shield**: `verifyNoMoreInteractions(mockRepo)` dipasang di Happy Path.
- [ ] **Happy Path**: Use Case menerima lemparan `Right(Entity)` dari Repository lalu `expect(result, Right(tEntity))` memastikan Usecase tidak memodifikasinya di pertengahan.
- [ ] **Error Path**: Verifikasi ketat `Left(Failure)` dilempar murni ke BLoC (Usecase mengkonsumsi *Left* tanpa try/catch terselubung yg salah konfigurasi).
- [ ] Mock di-generate: `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] Lulus: `fvm flutter test test/core/domain/usecases/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
