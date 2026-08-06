import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../common/global/router/app_router.dart';
import '../../common/global/router/router_utils.dart';

// -----------------------------------------------------------------------------
// DeepLinkService
//
// Mendengarkan deep link masuk (komerce://...) dan mengarahkan ke halaman
// yang sesuai via GoRouter.
//
// Saat ini hanya menangani:
//   komerce://reset-password?code=xxx atau https://reset-password?code=xxx → NewForgotPasswordPage
//
// Cara pakai: panggil DeepLinkService.instance.init() di main.dart
// setelah DI dan router sudah siap.
// -----------------------------------------------------------------------------

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  /// Inisialisasi listener. Panggil sekali saja setelah app siap.
  Future<void> init() async {
    _appLinks = AppLinks();

    // 1) Cek apakah app dibuka dari deep link (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('DeepLink [cold start]: $initialUri');
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLink getInitialLink error: $e');
    }

    // 2) Listen deep link saat app sudah berjalan (warm start)
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('DeepLink [warm]: $uri');
        _handleUri(uri);
      },
      onError: (err) {
        debugPrint('DeepLink stream error: $err');
      },
    );
  }

  /// Route URI masuk ke halaman yang sesuai.
  void _handleUri(Uri uri) {
    // komerce://reset-password?code=xxx atau https://reset-password?code=xxx
    if (uri.host == 'reset-password' || uri.path == '/reset-password') {
      final code = uri.queryParameters['code'];
      debugPrint('DeepLink → navigasi ke NewForgotPassword, code=$code');

      // Tutup semua dialog/bottom sheet yang mungkin masih terbuka
      // sebelum navigasi, agar tidak crash karena deactivated context.
      final navigatorState = AppRouter.navigatorKey.currentState;
      if (navigatorState != null) {
        // Pop semua overlay (dialog, bottom sheet) sampai tidak ada lagi
        while (navigatorState.canPop()) {
          navigatorState.pop();
        }
      }

      // Beri sedikit delay agar pop selesai sebelum navigasi
      Future.delayed(const Duration(milliseconds: 100), () {
        AppRouter.router.goNamed(
          PAGES.newForgotPassword.screenName,
          queryParameters: {
            if (code != null) 'code': code,
          },
        );
      });
    } else {
      debugPrint('DeepLink: unhandled URI → $uri');
    }
  }

  /// Bersihkan listener (biasanya tidak perlu dipanggil).
  void dispose() {
    _sub?.cancel();
  }
}
