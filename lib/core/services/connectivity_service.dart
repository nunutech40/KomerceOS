import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// -----------------------------------------------------------------------------
// InternetChecker
//
// Typedef untuk fungsi pengecekan internet sungguhan.
// Dipisah agar bisa di-mock di unit test tanpa bergantung pada DNS lookup nyata.
// -----------------------------------------------------------------------------
typedef InternetChecker = Future<bool> Function();

/// Default implementation: DNS lookup ke google.com
Future<bool> defaultInternetChecker() async {
  try {
    final addresses = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    return addresses.isNotEmpty && addresses.first.rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  } catch (_) {
    return false;
  }
}

// -----------------------------------------------------------------------------
// ConnectivityService
//
// Memantau status koneksi internet secara real (DNS lookup), bukan hanya
// status jaringan (WiFi connected tapi tidak ada internet tetap dianggap offline).
//
// Kompatibel dengan connectivity_plus ^4.x yang menggunakan ConnectivityResult
// tunggal (bukan List<ConnectivityResult> yang merupakan API v5.x+).
//
// Usage:
//   final service = ConnectivityService();
//   service.onConnectivityChanged.listen((isConnected) { ... });
//
// Testing:
//   final service = ConnectivityService.forTest(
//     connectivity: mockConnectivity,
//     internetChecker: () async => false,
//   );
// -----------------------------------------------------------------------------

class ConnectivityService {
  ConnectivityService._internal()
      : _connectivity = Connectivity(),
        _internetChecker = defaultInternetChecker;

  /// Constructor khusus test — inject dependency dari luar
  @visibleForTesting
  ConnectivityService.forTest({
    required Connectivity connectivity,
    required InternetChecker internetChecker,
  })  : _connectivity = connectivity,
        _internetChecker = internetChecker;

  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity;
  final InternetChecker _internetChecker;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  // connectivity_plus ^4.x: stream emits ConnectivityResult (single)
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isConnected = true;
  bool _initialized = false;

  /// Stream status koneksi: `true` = ada internet, `false` = tidak ada
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Status koneksi terakhir yang diketahir
  bool get isConnected => _isConnected;

  // ---------------------------------------------------------------------------
  // Initialize — panggil sekali saat app start
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Cek awal — checkConnectivity() returns ConnectivityResult (single) di v4
    final result = await _connectivity.checkConnectivity();
    _isConnected = await _hasRealInternet(result);
    _controller.add(_isConnected);

    // Listen perubahan — onConnectivityChanged emits ConnectivityResult (single) di v4
    _subscription = _connectivity.onConnectivityChanged.listen(
      (result) async {
        final hasInternet = await _hasRealInternet(result);
        if (hasInternet != _isConnected) {
          _isConnected = hasInternet;
          _controller.add(_isConnected);
          debugPrint(
              '[ConnectivityService] Internet: ${_isConnected ? "CONNECTED" : "DISCONNECTED"}');
        }
      },
    );
  }

  /// Memaksa pengecekan status internet secara aktif/manual
  Future<bool> forceCheck() async {
    final result = await _connectivity.checkConnectivity();
    final hasInternet = await _hasRealInternet(result);
    if (hasInternet != _isConnected) {
      _isConnected = hasInternet;
      _controller.add(_isConnected);
      debugPrint(
          '[ConnectivityService] Force Check Internet: ${_isConnected ? "CONNECTED" : "DISCONNECTED"}');
    }
    return _isConnected;
  }

  // ---------------------------------------------------------------------------
  // Validasi internet sungguhan via DNS lookup (atau injected checker)
  // ---------------------------------------------------------------------------
  Future<bool> _hasRealInternet(ConnectivityResult result) async {
    // Jika tidak ada koneksi sama sekali, langsung false tanpa DNS lookup
    if (result == ConnectivityResult.none) {
      return false;
    }
    return _internetChecker();
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
