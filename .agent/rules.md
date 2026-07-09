# Project Rules — komtim_partner

Rules ini selalu berlaku di setiap interaksi. Tidak perlu dipanggil — otomatis aktif.

## Architecture

Project ini menggunakan **Clean Architecture** 3-layer:

```
lib/
├── features/<fitur>/       ← Presentation (BLoC + View) — ISOLATED per fitur
│   ├── bloc/
│   └── view/
├── core/
│   ├── domain/             ← Domain (Entity, Repository interface, UseCase)
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── usecases/
│   │   └── managers/
│   └── data/               ← Data (Response model, Repository impl, DataSource)
│       ├── models/
│       ├── repositories/
│       ├── datasources/
│       │   ├── remote/
│       │   └── preferences/
│       └── apiservice/
├── DI/                     ← Dependency Injection (get_it)
├── config/                 ← Router, flavor
└── common/                 ← Shared utils, constants, failure types
```

## Naming Conventions

| Layer | Nama File | Contoh |
|---|---|---|
| Entity | `<fitur>_model.dart` | `login_model.dart` |
| Response (data model) | `<fitur>_response.dart` | `login_response.dart` |
| Remote DataSource | `<fitur>_remote_datasource.dart` | `auth_remote_datasource.dart` |
| Repository Interface | `<fitur>_repository.dart` | `auth_repository.dart` |
| Repository Impl | `<fitur>_repository_impl.dart` | `auth_repository_impl.dart` |
| Use Case | `<aksi>_<fitur>_use_case.dart` | `do_login_use_case.dart` |
| BLoC | `<fitur>_bloc.dart` | `login_bloc.dart` |
| Event | `<fitur>_event.dart` | `login_event.dart` |
| State | `<fitur>_state.dart` | `login_state.dart` |

## Patterns Wajib

1. **Repository extends BaseRepository** — selalu gunakan `executeEither()` untuk error handling otomatis
2. **DataSource inject DioClient + DioResponseParser** — jangan instantiate sendiri
3. **DI urutan:** DataSource → Repository → UseCase → BLoC
4. **BLoC inject UseCase** — jangan inject Repository langsung ke BLoC
5. **Token di SecureStorage** — JANGAN simpan plain text di SharedPreferences
6. **Response.toEntity()** — selalu konversi Response ke Entity sebelum naik ke domain layer
7. **Equatable** — semua Entity, Event, State harus extends Equatable
8. **Either<Failure, T>** — selalu gunakan dartz Either untuk return dari Repository/UseCase

## Shared Files — Jangan Modifikasi Tanpa Impact Check

File-file ini dipakai oleh banyak fitur. Modifikasi = potensi regresi:

- `lib/core/data/apiservice/dio_client.dart`
- `lib/core/data/apiservice/dio_response_parser.dart`
- `lib/core/data/repositories/base_repository.dart`
- `lib/core/data/datasources/preferences/shared_pref.dart`
- `lib/core/data/datasources/preferences/secure_storage_service.dart`
- `lib/common/failure.dart`

**Menambahkan** ke file ini (endpoint baru, key baru) = OK.
**Mengubah behavior** yang sudah ada = WAJIB grep_search dulu siapa yang pakai.

## FVM & Flavor

- **FVM:** Flutter `3.35.5` (selalu pakai `fvm flutter ...`)
- **Flavor:** `dev`, `staging`, `production`
- **Build:** `fvm flutter run --flavor dev --dart-define=FLAVOR=dev`

## Testing

### Setup
- Mock library: `mockito` + `@GenerateMocks`
- BLoC test: `bloc_test` package
- Generate mock: `fvm dart run build_runner build --delete-conflicting-outputs`
- Run test: `fvm flutter test`

### ⛔ LARANGAN KERAS — WAJIB DIPATUHI

> **JANGAN pernah memodifikasi file implementasi di `lib/` saat sedang membuat unit test.**
>
> Unit test harus ditulis untuk menguji kode yang **sudah ada**, bukan untuk membenarkan refactoring yang tidak diminta.
>
> Jika implementasi terlihat memiliki bug saat menulis test:
> - Tulis test yang **mencerminkan behavior implementasi yang ada** (termasuk bug-nya)
> - Dokumentasikan temuan bug itu sebagai komentar di dalam test
> - **JANGAN ubah implementasi tanpa perintah eksplisit dari user**

```dart
// ✅ BENAR — test mengikuti behavior implementasi asli
// CATATAN: Implementasi saat ini hanya hapus local jika remote return true.
// Jika remote throw exception, removeDataPref() tidak dipanggil.
test('TIDAK memanggil removeDataPref saat remote throw exception', () async {
  when(mockRemote.doLogout()).thenThrow(Exception());
  await repository.doLogout();
  verifyNever(mockSharedPref.removeDataPref()); // ← sesuai kode asli
});

// ❌ SALAH — mengubah implementasi dulu baru buat test yang pass
// Ini bukan tugas saat diminta bikin unit test!
```

### Standar Kualitas — Wajib Diterapkan di Setiap Test

Setiap method wajib di-test dengan **3 path**:

| Path | Definisi |
|---|---|
| **Happy Path** | Semua berjalan normal → return value dengan **field yang dicek** |
| **Error Path** | Exception/Failure → cek **tipe** Failure + **message**-nya |
| **Edge Path** | Side effect, input tidak valid, parsing mismatch |

### Anti-Pattern yang DILARANG

```dart
// ❌ Body tidak diverifikasi (dead variable)
final tBody = {'key': 'val'};
verify(mockClient.post(endpoint, data: anyNamed('data'))); // body tidak dicek!

// ❌ Exception assertion terlalu generic
expect(() => method(), throwsException); // tipe apa? message apa?

// ❌ Tidak cek field hasil
expect(result.isRight(), isTrue); // isi Right-nya benar tidak?
expect: () => [isA<XyzLoaded>()],  // data di Loaded benar tidak?
```

### Pattern yang BENAR

```dart
// ✅ Verifikasi exact body
verify(mockClient.post(endpoint, data: tBody)).called(1);

// ✅ Assert tipe + message
throwsA(isA<ServerException>().having((e) => e.message, 'message', 'Unauthorized'));

// ✅ Cek field spesifik
result.fold((f) { expect(f, isA<ConnectionFailure>()); expect(f.message, 'Request timeout'); }, (_) => fail(''));

// ✅ Cek field entity/state
expect(state.data.username, 'john_doe');
expect(state.message, tFailure.message);
```

### Tentang Test yang Fail (Termometer Bug)

> ⚠️ **Jika test yang kamu tulis ternyata MERAH (fail) setelah di-run:**
>
> 1. Periksa dulu: apakah ekspektasi/mock di test salah konfigurasinya?
> 2. Jika test sudah ditulis dengan standard ketat (bukan salah test) tapi MERAH karena berlawanan dengan implementasi saat ini, maka **BIARKAN TEST TERSEBUT MERAH.**
> 3. Tulis test *se-ideal mungkin menurut best practice*, jangan longgarkan *assertion* (seperti pakai `any` alih-alih nilai exact) hanya untuk mendamaikan kegagalan. 
> 4. **JANGAN AUTO-REFACTOR KODE IMPLEMENTASINYA DI `lib/`**.
> 5. **Laporan bug terbaik adalah Output Terminal Test yang Berwarna Merah** itu sendiri. Biarkan merah, jadikan itu sebagai alat ukur otentik bagi developer untuk berdiskusi dengan timnya terkait perbaikan implementasi. Test yang melemah demi warna hijau adalah dosa "Asal Bapak Senang" (ABS).
- `unit-test-datasource-remote` → Remote DataSource
- `unit-test-datasource-local` → Local DataSource (SharedPref)
- `unit-test-repository` → Repository Implementation
- `unit-test-usecase` → UseCase Domain Layer
- `unit-test-bloc` → BLoC Presentation Layer
