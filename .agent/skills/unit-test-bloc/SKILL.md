---
name: unit-test-bloc
description: Panduan unit test untuk BLoC (Presentation Layer). Test transaksi state dengan bloc_test, urutan ekspektasi kejadian berantai.
---

# Skill: Unit Test — BLoC (Presentation Layer)

## Aturan Folder
**Test file HARUS mirror folder lib:**
```
lib/features/xyz/presentation/bloc/xyz_bloc.dart
 → test/features/xyz/presentation/bloc/xyz_bloc_test.dart
```

## Filosofi
**FOKUS UTAMA:** BLoC adalah **Mesin State Transaksional**. Fokus pengujian bukanlah apa yang dijalankan di background, melainkan **Apakah `Event` yang masuk mampu memproduksi URUTAN `State` (timeline) yang tepat** bagi UI (contoh: `Initial` ➔ `Loading` ➔ `Success`). Tiap pengujian harus `Isolated` antar event dengan memanggil `tearDown(() => bloc.close())`.

---

## Tiga Skenario Wajib (Paths) pada BLoC

| Path | Kejadian | Ekspektasi (`expect: () => [...]`) |
|---|---|---|
| **a. Happy Path** | Event dikirim, UseCase me-return `Right()`. | Memancarkan sekumpulan state berurutan murni: <br> `[State(loading), State(success)]`<br> *Pastikan mengecek nilai variabel/object yang ada di dalam state success tersebut (ex: `state.user` valid).* |
| **b. Error Path** | Event dikirim, UseCase me-return `Left(Failure)`. | Memancarkan status penolakan beserta pesan: <br> `[State(loading), State(error, message)]`<br> *Wajib mengecek pesan error terpasang sesuai `failure.message`.* |
| **c. Edge Path <br>*(Kasus Inkonsisten)* **| Momen di luar dugaan (Rantai kejadian). <br>Misal: Login berhasil, tapi saat app narik data GetProfile, server nge-lag. | State harus tetap konsisten merespon skenario gagal di tengah jalan. <br>Misal: Tetap emit `State(authenticated)` walau `user: null`, agar App tidak terlempar ke layar Auth hanya karena lag jaringan. |

---

## Template Lengkap Blok Uji `blocTest`

```dart
// test/features/xyz/presentation/bloc/xyz_bloc_test.dart

// =============================================================================
// PANDUAN: BLoC — Urutan Transaksi State
// =============================================================================
// 1. Initial : Blok tes untuk memastikan state pembuka sesuai
// 2. Happy   : [Loading, Success(data_akurat)] saat usecase Right
// 3. Error   : [Loading, Error(message)] saat usecase Left
// 4. Edge    : Validasi kasus anomali / pemanggilan Usecase berantai inkonsisten
// WAJIB: Pastikan blocTest melakukan bloc.close() jika tidak dicover di tearDown
// =============================================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([GetXyzUseCase, DoAnotherXyzUseCase])
void main() {
  late XyzBloc bloc;
  late MockGetXyzUseCase mockGetUseCase;
  late MockDoAnotherXyzUseCase mockAnotherUseCase;

  setUpAll(() {
     // Bila ada passing custom object ke parameter Usecase (any)
     // registerFallbackValue(CustomParams());
  });

  setUp(() {
    mockGetUseCase = MockGetXyzUseCase();
    mockAnotherUseCase = MockDoAnotherXyzUseCase();
    bloc = XyzBloc(
      getUseCase: mockGetUseCase,
      anotherUseCase: mockAnotherUseCase,
    );
  });

  tearDown(() {
    bloc.close(); // ← WAJIB, mencegah resource (stream) leak yang merusak test di file lain!
  });

  // ── Fixture ──────────────────────────────────────────────────────────────
  const tId = '1';
  final tEntity = XyzModel(id: 1, name: 'Test');
  final tFailure = ServerFailure(message: 'Data tidak valid');

  test('initial state harus berstatus initial', () {
    expect(bloc.state, isA<XyzInitial>());
  });

  group('Hit API XyzEvent', () {

    // ── a. HAPPY PATH ───────────────────────────────────────────────────────
    blocTest<XyzBloc, XyzState>(
      'harus emit [Loading, Loaded] dengan data yang akurat saat XyzEvent dipanggil',
      build: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Right(tEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchXyzEvent(tId)),
      expect: () => [
        isA<XyzLoading>(), 
        isA<XyzLoaded>().having((state) => state.data, 'data akurat', tEntity),
      ],
      verify: (_) {
         // (Opsional) pastikan method berjalan jika dirasa krusial
         verify(mockGetUseCase.call(tId)).called(1);
      }
    );

    // ── b. ERROR PATH ───────────────────────────────────────────────────────
    blocTest<XyzBloc, XyzState>(
      'harus emit [Loading, Error] memuat errorMessage yang setara dengan Left(Failure)',
      build: () {
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Left(tFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchXyzEvent(tId)),
      expect: () => [
        isA<XyzLoading>(),
        isA<XyzError>().having((state) => state.message, 'error message', 'Data tidak valid'),
      ],
    );

    // ── c. EDGE PATH (INKONSISTENS / KEJADIAN BERANTAI) ──────────────────────
    blocTest<XyzBloc, XyzState>(
      'harus TETAP emit [Loading, Success(data: null)] tanpa melempar Error walau fetch tambahan gagal ditengah jalan (Edge Path)',
      build: () {
        // Step 1: Hitungan utama berhasil
        when(mockGetUseCase.call(any)).thenAnswer((_) async => Right(tEntity));
        // Step 2: Fetch background tambahan tiba-tiba lag / Network Error, kita tes bloc agar kebal
        when(mockAnotherUseCase.call(any)).thenAnswer((_) async => const Left(NetworkFailure(message: 'Timeout')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchXyzEvent(tId)),
      expect: () => [
        isA<XyzLoading>(),
        // Ekspektasinya BLoC bisa menutupi error background menjadi state Success (meski data minor gaada)
        isA<XyzLoaded>().having((state) => state.minorData, 'no minor data', isNull), 
      ],
    );
  });
}
```

---

## ✅ Checklist Kualitas

- [ ] File test diletakan spesifik mereplikasi letaknya `test/features/<fitur>/bloc/`
- [ ] Tersedia `blocTest` khusus untuk package BLoC dan penempatan dependencies diselesaikan via `@GenerateMocks([UseCase1, UseCase2])`
- [ ] Tersedia `registerFallbackValue` (dari paket Mockito) untuk *custom object parameter* (jika method call pakai object `any()`).
- [ ] `tearDown(() { bloc.close(); })` dieksekusi agar tidak terjadi leak aliran stream antar-tes.
- [ ] **Initial Check**: `expect(bloc.state, target)` diletakan di luar blocTest untuk mendeteksi constructor state.
- [ ] **Happy Path**: urutan ekspektasi mutlak tepat (misal: Loading -> Success), dan status akhir dicek isinya dengan matcher `.having()`.
- [ ] **Error Path**: urutan ekspektasi error benar, dan pesan yang dilemparkan sesuai dengan `Left(failure)`.
- [ ] **Edge Path (Opsional namun bernilai tinggi)**: Apabila dalam satu Event terdapat 2 logika UseCase. Bagaimana skenario bila proses A berjalan namun B gagal di pertengahan? Mampu mencegah App Freeze.
- [ ] Lulus test: `fvm flutter test test/features/<fitur>/bloc/`

---

## ⛔ Jika Test Merah — Protokol Wajib (Termometer Bug)

> 1. Cek apakah ekspektasi / mock setup unit test-nya salah?
> 2. Tetap tulis Test se-ideal mungkin sesuai best-practice. Jangan disesuaikan (ABS) dengan kode yang buruk.
> 3. **JANGAN AUTO-REFACTOR KODE `lib/`**. 
> 4. Biarkan test-nya MERAH di terminal. Laporan Output Terminal kegagalan itu adalah Bukti (Laporan Resmi) bagi developer untuk didiskusikan! Jangan rendahkan ekspektasi `assertion` di test.
