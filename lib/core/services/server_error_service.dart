import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

// -----------------------------------------------------------------------------
// ServerErrorService
//
// Singleton global yang bisa menampilkan Bottom Sheet "Server Error"
// tanpa memerlukan BuildContext dari caller (termasuk dari Dio interceptor).
//
// Setup (di main.dart, setelah AppRouter.navigatorKey tersedia):
//   ServerErrorService().setNavigatorKey(AppRouter.navigatorKey);
//
// Usage (dari interceptor atau mana pun):
//   ServerErrorService().showServerError(onRetry: () { ... });
// -----------------------------------------------------------------------------

class ServerErrorService {
  ServerErrorService._internal();
  static final ServerErrorService _instance = ServerErrorService._internal();
  factory ServerErrorService() => _instance;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isShowing = false;

  /// Dipanggil sekali saat app start, setelah navigatorKey tersedia.
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // ---------------------------------------------------------------------------
  // Show server error bottom sheet
  // ---------------------------------------------------------------------------

  /// Tampilkan bottom sheet Server Error.
  /// [onRetry] opsional — jika null tombol "Coba Lagi" hanya menutup bottom sheet.
  void showServerError({VoidCallback? onRetry}) {
    if (_isShowing) return; // Cegah duplikasi
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    _isShowing = true;

    DsBottomSheet.show(
      context: context,
      isDismissible: true,
      title: 'Server Error',
      description:
          'Terjadi kendala pada sistem. Silakan\ncoba kembali beberapa saat lagi.',
      image: SvgPicture.asset(
        'assets/images/superapp/auth/server_error.svg',
        width: 160,
        height: 200,
      ),
      secondaryButtonText: 'Kembali',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
      primaryButtonText: 'Coba Lagi',
      onPrimaryPressed: () {
        Navigator.pop(context);
        onRetry?.call();
      },
      onClosePressed: () {
        Navigator.pop(context);
      },
    ).whenComplete(() {
      _isShowing = false;
    });
  }
}
