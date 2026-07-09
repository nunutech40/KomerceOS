// =============================================================================
// Unit Test: ConnectivityService
// =============================================================================
// Menguji ConnectivityService.forTest() dengan mock Connectivity dan
// InternetChecker yang diinjeksi — tanpa DNS lookup nyata.
//
// Skenario yang diuji:
//   1. initialize() — ConnectivityResult.none     → isConnected false
//   2. initialize() — WiFi + internet OK          → isConnected true
//   3. initialize() — WiFi + DNS gagal (captive)  → isConnected false
//   4. Stream — koneksi berubah ke none           → emit false setelah event awal
//   5. Stream — koneksi kembali ke wifi + DNS OK  → emit true setelah event awal
//   6. Stream — nilai sama, tidak emit ulang      → tidak ada event tambahan
//   7. initialize() idempotent                    → checkConnectivity dipanggil 1x
// =============================================================================

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/services/connectivity_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'connectivity_service_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<ConnectivityResult> connectivityStreamController;

  // ---------------------------------------------------------------------------
  // Helper: buat ConnectivityService.forTest()
  // ---------------------------------------------------------------------------
  ConnectivityService makeService({required bool internetResult}) {
    return ConnectivityService.forTest(
      connectivity: mockConnectivity,
      internetChecker: () async => internetResult,
    );
  }

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityStreamController =
        StreamController<ConnectivityResult>.broadcast();

    when(mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);
  });

  tearDown(() {
    connectivityStreamController.close();
  });

  // ---------------------------------------------------------------------------
  // Group 1: initialize() — cek state setelah init
  // ---------------------------------------------------------------------------
  group('initialize()', () {
    test(
      'isConnected false saat ConnectivityResult.none (tanpa DNS lookup)',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        final service = makeService(internetResult: true); // checker tidak dipanggil
        await service.initialize();

        expect(service.isConnected, false);
      },
    );

    test(
      'isConnected true saat WiFi dan DNS lookup berhasil',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        final service = makeService(internetResult: true);
        await service.initialize();

        expect(service.isConnected, true);
      },
    );

    test(
      'isConnected false saat WiFi tapi DNS lookup gagal (captive portal)',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        final service = makeService(internetResult: false);
        await service.initialize();

        expect(service.isConnected, false);
      },
    );

    test(
      'emit nilai awal ke stream setelah initialize()',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.mobile);

        final service = makeService(internetResult: true);

        // Pasang listener SEBELUM initialize() — broadcast stream tidak buffer
        final emitted = <bool>[];
        service.onConnectivityChanged.listen(emitted.add);

        await service.initialize();
        // Beri waktu stream memproses event async
        await Future.delayed(const Duration(milliseconds: 10));

        expect(emitted, [true]);
      },
    );

    test(
      'initialize() kedua kalinya tidak melakukan apa-apa (idempotent)',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        final service = makeService(internetResult: true);
        await service.initialize();
        await service.initialize(); // panggil kedua kali

        // checkConnectivity hanya dipanggil 1x
        verify(mockConnectivity.checkConnectivity()).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Group 2: Stream perubahan konektivitas (setelah initialize)
  // ---------------------------------------------------------------------------
  group('onConnectivityChanged stream', () {
    test(
      'emit false saat koneksi berubah ke none (setelah mulai dari wifi)',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        final service = makeService(internetResult: true);

        // Pasang listener dan tunggu initialize selesai
        final emitted = <bool>[];
        service.onConnectivityChanged.listen(emitted.add);
        await service.initialize();
        await Future.delayed(const Duration(milliseconds: 10));

        // Bersihkan event awal (nilai true dari initialize)
        final initialCount = emitted.length;

        // Simulasi koneksi mati — internetChecker tidak relevan untuk none
        connectivityStreamController.add(ConnectivityResult.none);
        await Future.delayed(const Duration(milliseconds: 50));

        // Hanya event setelah initialCount yang kita cek
        final newEvents = emitted.sublist(initialCount);
        expect(newEvents, [false]);
        expect(service.isConnected, false);
      },
    );

    test(
      'emit true saat koneksi kembali ke wifi setelah offline',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        // Mulai dari offline, internetChecker selalu true (DNS OK)
        final service = ConnectivityService.forTest(
          connectivity: mockConnectivity,
          internetChecker: () async => true,
        );

        final emitted = <bool>[];
        service.onConnectivityChanged.listen(emitted.add);
        await service.initialize();
        await Future.delayed(const Duration(milliseconds: 10));

        final initialCount = emitted.length; // [false] dari initialize

        // Simulasi koneksi kembali
        connectivityStreamController.add(ConnectivityResult.wifi);
        await Future.delayed(const Duration(milliseconds: 50));

        final newEvents = emitted.sublist(initialCount);
        expect(newEvents, [true]);
        expect(service.isConnected, true);
      },
    );

    test(
      'tidak emit event tambahan jika status koneksi tidak berubah',
      () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        final service = makeService(internetResult: true);

        final emitted = <bool>[];
        service.onConnectivityChanged.listen(emitted.add);
        await service.initialize();
        await Future.delayed(const Duration(milliseconds: 10));

        final initialCount = emitted.length; // [true] dari initialize

        // Simulasi event wifi lagi — status tidak berubah (masih true)
        connectivityStreamController.add(ConnectivityResult.wifi);
        await Future.delayed(const Duration(milliseconds: 50));

        // Tidak ada event baru setelah event awal
        final newEvents = emitted.sublist(initialCount);
        expect(newEvents, isEmpty,
            reason: 'Tidak boleh emit ulang jika status sama');
      },
    );
  });
}
