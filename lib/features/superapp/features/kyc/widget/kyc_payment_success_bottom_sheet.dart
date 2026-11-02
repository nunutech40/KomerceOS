import 'package:flutter/material.dart';
import 'kyc_success_bottom_sheet.dart';

export 'kyc_success_bottom_sheet.dart';

/// # KycPaymentSuccessBottomSheet
///
/// Modal bottom sheet notifikasi sukses pembayaran biaya verifikasi KYC (Rp 25.000).
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu setelah API potong saldo (`/api/v1/partner/ktp-verification/pay`) sukses di [KycVerificationBottomSheet].
/// - Menampilkan judul "Pembayaran Berhasil", pesan sukses, dan tombol interaktif "Oke".
///
/// ### 🔄 Alur & Interaksi:
/// 1. Modal muncul dalam keadaan diam (tidak langsung redirect). Tombol bertuliskan **"Oke"**.
/// 2. User membaca konfirmasi sukses dan menekan tombol **"Oke"**.
/// 3. Tombol otomatis berubah menjadi loading state dengan spinner dan teks **"Redirecting..."**.
/// 4. Modal mengunci interaksi kembali (`PopScope(canPop: false)`).
/// 5. Setelah jeda transisi (~1.5 detik), modal sukses ditutup dan mengeksekusi [onAction]
///    untuk melanjutkan ke alur pengisian identitas ([KycIdentityBottomSheet]).
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// KycPaymentSuccessBottomSheet.show(
///   context,
///   buttonText: 'Oke',
///   onAction: () {
///     // Lanjut ke modal pengisian identitas
///     KycIdentityBottomSheet.show(context, onSubmit: () => navigateToKycForm());
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [subtitle] : Penjelasan tambahan (default: `'Paid verifikasi telah berhasil dibeli.'`).
/// - [buttonText] / [buttonLabel] : Label tombol saat diam (default: `'Oke'`).
/// - [loadingText] : Teks saat tombol ditekan dan masuk mode loading (default: `'Redirecting...'`).
/// - [redirectDelay] : Durasi jeda animasi sebelum modal ditutup (default: `Duration(milliseconds: 1500)`).
/// - [onAction] : Callback yang dijalankan setelah modal ditutup untuk melanjutkan flow berikutnya.
/// - [backgroundColor] : Warna background modal (default: `Color(0xFFDCDCDC)`).
abstract final class KycPaymentSuccessBottomSheet {
  /// Helper statis untuk menampilkan modal sukses pembayaran KYC dengan transisi klik 'Oke' -> 'Redirecting...'.
  static Future<T?> show<T>(
    BuildContext context, {
    String? subtitle,
    String? buttonLabel,
    String? buttonText,
    String loadingText = 'Redirecting...',
    VoidCallback? onAction,
    Color? backgroundColor,
    Duration redirectDelay = const Duration(milliseconds: 1500),
  }) {
    final effectiveButtonText = buttonText ?? buttonLabel ?? 'Oke';
    bool isLoading = false;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return PopScope(
              canPop: !isLoading,
              child: KycSuccessBottomSheet(
                title: 'Pembayaran Berhasil',
                subtitle: subtitle ?? 'Paid verifikasi telah berhasil dibeli.',
                backgroundColor: backgroundColor ?? const Color(0xFFDCDCDC),
                isLoading: isLoading,
                loadingText: loadingText,
                buttonText: effectiveButtonText,
                showCloseButton: false,
                onButtonPressed: isLoading
                    ? null
                    : () async {
                        setModalState(() {
                          isLoading = true;
                        });

                        await Future.delayed(redirectDelay);

                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }

                        onAction?.call();
                      },
              ),
            );
          },
        );
      },
    );
  }
}

