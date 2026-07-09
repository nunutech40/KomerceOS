---
description: Membuat unit test dan mock per layer (datasource, repository, use case, BLoC) untuk fitur baru maupun fitur yang sudah ada
---

# Add Unit Test — komtim_partner

Entry point untuk menulis unit test. Bisa semua layer sekaligus atau satu per satu.

**Aturan: Test file HARUS mirror struktur folder `lib/`**

```
lib/core/data/models/xyz_response.dart
 → test/core/data/models/xyz_response_test.dart

lib/core/data/datasources/remote/xyz_remote_datasource.dart
 → test/core/data/datasources/remote/xyz_remote_datasource_test.dart

lib/core/data/repositories/xyz_repository_impl.dart
 → test/core/data/repositories/xyz_repository_impl_test.dart

lib/core/domain/usecases/get_xyz_use_case.dart
 → test/core/domain/usecases/get_xyz_use_case_test.dart

lib/features/xyz/bloc/xyz_bloc.dart
 → test/features/xyz/bloc/xyz_bloc_test.dart
```

---

## ⛔ LARANGAN KERAS — BACA SEBELUM MULAI

> **DILARANG ME-REFACTOR KODE IMPLEMENTASI DI `lib/`!**
>
> Jika dalam proses menulis test kamu menemukan bahwa kode implementasinya salah/penuh bug (misal method `save` tak dipanggil saat error):
> - Tulis test-nya dengan standar/aturan yang ketat (TUNTUT method `save` agar di `verify`).
> - Otomatis test-nya akan **MERAH**, dan **BIARKAN SAJA MERAH!**
> - **Test yang merah itu adalah Laporan Resmi yang diminta developer!** Jangan rendahkan ekspektasi `assertion` di test (ABS) cuma buat menyamakan dengan bug di implementasi.

---

## Mau Test Apa?

Pilih layer yang mau di-test. Setiap layer punya skill tersendiri:

| Layer | Skill | Kapan pakai? |
|---|---|---|
| Response Model | `unit-test-response` | Setelah bikin `*_response.dart` |
| Local DataSource | `unit-test-datasource-local` | Kalau ada SharedPref/SecureStorage |
| Remote DataSource | `unit-test-datasource-remote` | Setelah bikin `*_remote_datasource.dart` |
| Repository | `unit-test-repository` | Setelah bikin `*_repository_impl.dart` |
| UseCase | `unit-test-usecase` | Setelah bikin `*_use_case.dart` |
| BLoC | `unit-test-bloc` | Setelah bikin `*_bloc.dart` |

---

## Standar Kualitas Test (Wajib Dipahami)

Setiap layer punya **tiga path** yang harus di-cover:

| Path | Definisi | Contoh |
|---|---|---|
| **Happy Path** | Semua berjalan normal | Remote sukses → return model/entity dengan **field dicek** |
| **Error Path** | Exception/Failure yang diharapkan | DioException timeout → Left(ConnectionFailure) dengan **message dicek** |
| **Edge Path** | Kasus di luar dugaan / side effect | Parsing null, logout clean up tidak dipanggil, input kosong |

### Anti-pattern yang DILARANG

```dart
// ❌ Body tidak diverifikasi (dead variable)
final tBody = {'key': 'value'};
verify(mockClient.post(endpoint, data: anyNamed('data'))); // ← body tidak dicek!

// ❌ Exception assertion terlalu generic
expect(() => method(), throwsException); // ← tipe apa? message apa?

// ❌ Tidak cek field entity/state
expect(result.isRight(), isTrue); // ← isi Right-nya benar tidak?
expect: () => [isA<XyzLoaded>()],  // ← data di Loaded benar tidak?
```

### Pattern yang BENAR

```dart
// ✅ Verifikasi exact body
verify(mockClient.post(endpoint, data: tBody)).called(1);

// ✅ Assert tipe + message exception
throwsA(isA<ServerException>().having((e) => e.message, 'message', 'Unauthorized'));

// ✅ Cek field spesifik
expect(result, Right(tEntity));                  // Repository
expect(state.data.username, 'john_doe');         // BLoC — state Loaded
expect(state.message, tFailure.message);         // BLoC — state Error
expect(failure.message, 'Request timeout');      // Repository — ConnectionFailure
```

---

## Cara Pakai

### Semua layer sekaligus (full coverage satu fitur)
```
1. Baca implementasi yang akan di-test terlebih dahulu
2. → Jalankan skill `unit-test-response`
3. → Jalankan skill `unit-test-datasource-remote`
4. → Jalankan skill `unit-test-repository`
5. → Jalankan skill `unit-test-usecase`
6. → Jalankan skill `unit-test-bloc`
7. Generate mock + run test (lihat bagian bawah)
```

### Satu layer saja
```
Contoh: "bikin unit test repository auth"
1. Baca: lib/core/data/repositories/auth_repository_impl.dart
2. Baca: skill `unit-test-repository`
3. Buat test file di path yang benar
4. Generate mock + run test (lihat bagian bawah)
```

---

## Urutan yang Direkomendasikan

```
1. Response   → tidak butuh mock, murni parsing JSON
2. DataSource Remote → mock: DioClient, DioResponseParser
3. DataSource Local  → mock: SharedPreferences, FlutterSecureStorage
4. Repository        → mock: DataSource + SharedPref
5. UseCase           → mock: Repository
6. BLoC              → mock: UseCase — paling akhir, depend ke semua
```

---

## Setelah Test Ditulis

// turbo
```bash
# 1. Generate mock
fvm dart run build_runner build --delete-conflicting-outputs

# 2. Run semua test
fvm flutter test

# 3. Run per folder (lebih cepat)
fvm flutter test test/core/data/models/
fvm flutter test test/core/data/datasources/remote/
fvm flutter test test/core/data/datasources/preferences/
fvm flutter test test/core/data/repositories/
fvm flutter test test/core/domain/usecases/
fvm flutter test test/features/<fitur>/bloc/

# 4. Jika fvm tidak ditemukan di PATH, gunakan path absolut
~/.fvm/versions/<versi>/bin/flutter test <path>
```

---

## Upgrade Test yang Sudah Ada

Gunakan ini jika test **sudah ada** tapi belum memenuhi standar kualitas terbaru.
Berbeda dengan "bikin baru" — ini adalah **audit + perbaikan**, bukan tulis dari nol.

### Flow Audit

```
1. Baca test yang sudah ada
2. Bandingkan dengan skill yang sesuai (lihat tabel "Mau Test Apa?" di atas)
3. Identifikasi gap: path yang hilang, dead variable, assertion yang lemah
4. Perbaiki in-place — JANGAN tulis ulang seluruh file jika tidak perlu
5. Generate mock + run test
```

### Contoh Prompt

```
# Satu layer
"@[/add_unit_test] upgrade unit test remote datasource auth 
 sesuai standar skill terbaru"

# Specific gap
"@[/add_unit_test] perbaiki unit test repository auth — 
 tambahkan edge path dan verifikasi exact body yang masih pakai anyNamed"

# Semua layer satu fitur
"@[/add_unit_test] audit dan upgrade semua unit test fitur auth 
 (datasource, repository, usecase, bloc) sesuai standar terbaru"
```

### Yang Dicek Saat Audit (Gap Paling Umum)

| Gap | Gejala | Perbaikan |
|---|---|---|
| Dead variable | `tBody` dideklarasi tapi tidak dipakai di `verify` | Ganti `anyNamed('data')` → `tBody` exact |
| Error assertion generic | `throwsException` tanpa tipe | Tambah `.having(...)` atau minimal `isA<TipeException>()` |
| Missing Error path | Group hanya punya 1 test (happy) | Tambah test throw Exception + DioException |
| Missing Edge path | Tidak ada test side-effect / null / input kosong | Tambah sesuai konteks method |
| Field tidak dicek | `expect(result.isRight(), isTrue)` saja | Tambah `result.fold(...)` cek field spesifik |
| BLoC tanpa tearDown | `bloc.close()` tidak dipanggil | Tambah `tearDown(() => bloc.close())` |
| Missing `called(1)` | `verify(mock.method())` tanpa `.called(1)` | Tambah `.called(1)` untuk pastikan dipanggil tepat 1x |

### Tentang Test yang Fail (Termometer Bug)

> ⚠️ **Jika test yang dibuat ternyata MERAH (fail) setelah diuji:**
>
> 1. Pastikan dulu tesnya tidak dikonfigurasi salah (mock keliru dsb).
> 2. Tetap jalankan standar rules test ketat walau menyebabkan merah pada kode asli.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. Test dibuat untuk membedah. Jika testnya merah, biarkan! Sampaikan Output Terminal Gagal itu kepada team. Itu adalah "Laporan Valid" yang siap didiskusikan developer. Semudah *"Jangan rusak termometernya kalau tahu pasiennya lagi demam"*.

---

## Self-Review Sebelum Selesai

Sebelum declare "test sudah selesai", tanyakan ke diri sendiri:

- [ ] Semua method di class sudah punya group test?
- [ ] Setiap group punya minimal 3 path (happy, error, edge)?
- [ ] Semua `tBody` / `tQueryParams` fixture **dipakai** di `verify`, bukan dead variable?
- [ ] Assertion di error path cek tipe Failure: `isA<ConnectionFailure>()` / `isA<ServerFailure>()`?
- [ ] Field entity dicek (bukan hanya `isRight()` / `isLeft()`)?
- [ ] BLoC test ada `tearDown(() => bloc.close())`?
- [ ] Mock di-generate dan semua test lulus?
