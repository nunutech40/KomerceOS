import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/connectivity_service.dart';
import '../pages/no_internet_page.dart';

// -----------------------------------------------------------------------------
// ConnectivityWrapper
//
// Widget global yang dipasang tepat di bawah MyApp dan di atas MaterialApp.router.
// Mendengarkan ConnectivityService dan:
//   - Saat internet TERPUTUS → overlay NoInternetPage di atas semua halaman
//   - Saat internet KEMBALI  → hilangkan overlay secara otomatis
//
// Menggunakan Stack + Visibility agar TIDAK mengganggu GoRouter navigator.
// Sebelumnya pakai navigator.push/pop yang bisa konflik dengan GoRouter's
// declarative routing (go() rebuild stack → pop malah pop GoRouter route).
// -----------------------------------------------------------------------------

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;
  bool _showNoInternet = false;

  @override
  void initState() {
    super.initState();
    _service = ConnectivityService();
    // Daftarkan listener SEBELUM initialize agar tidak ada event yang terlewat
    _subscription = _service.onConnectivityChanged.listen(_onConnectivityChanged);
    _service.initialize().then((_) {
      // Cek kondisi awal setelah inisialisasi selesai
      if (mounted && !_service.isConnected && !_showNoInternet) {
        setState(() {
          _showNoInternet = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(bool isConnected) {
    if (!mounted) return;

    if (!isConnected && !_showNoInternet) {
      setState(() {
        _showNoInternet = true;
      });
    } else if (isConnected && _showNoInternet) {
      setState(() {
        _showNoInternet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Stack agar NoInternetPage menjadi overlay di atas child.
    // Ini TIDAK mengganggu GoRouter navigation stack sama sekali.
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // Child (MaterialApp.router) selalu di-render di bawah
        widget.child,

        // Overlay NoInternetPage — tampil/hilang via AnimatedSwitcher
        if (_showNoInternet)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showNoInternet ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const NoInternetPage(),
            ),
          ),
      ],
    );
  }
}
