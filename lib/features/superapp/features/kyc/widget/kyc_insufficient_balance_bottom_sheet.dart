import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';

/// # KycInsufficientBalanceBottomSheet
///
/// Bottom sheet peringatan ketika saldo Kompay user tidak mencukupi untuk melakukan
/// pembayaran biaya verifikasi KYC (Rp 25.000).
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu otomatis dari [KycVerificationBottomSheet] ketika user menekan "Ajukan Verifikasi",
///   tetapi saldo akunnya kurang dari nominal yang ditentukan (`currentBalance < totalAmount`).
/// - Menampilkan rincian transparan: Total Biaya, Saldo Kompay Saat Ini, dan Kekurangan Saldo (merah).
///
/// ### 🔄 Alur & Posisi dalam User Journey:
/// 1. User berniat mengajukan KYC di [KycVerificationBottomSheet].
/// 2. Pengecekan saldo mendeteksi kekurangan dana -> tampilkan [KycInsufficientBalanceBottomSheet.show].
/// 3. User menekan "Top Up Sekarang" (`onTopup`) -> Tutup bottom sheet & navigasi ke `TopupPage`.
/// 4. User menekan "Batal" (`onCancel`) -> Bottom sheet tertutup.
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycInsufficientBalanceBottomSheet.show(
///   context,
///   totalAmount: 25000,
///   currentBalance: userProfile.kompayBalance,
///   onTopup: () {
///     Navigator.pop(context); // Tutup modal
///     Navigator.push(
///       context,
///       MaterialPageRoute(builder: (_) => const TopupPage()),
///     );
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [totalAmount] : Total biaya yang dibutuhkan (default: `25000`).
/// - [currentBalance] : Saldo Kompay aktual milik user saat ini (default: `0`).
/// - [onTopup] : Callback saat tombol "Top Up Sekarang" ditekan.
/// - [onCancel] : Callback saat tombol "Batal" atau tombol close (X) ditekan. Defaults ke `Navigator.pop(context)`.
/// - [title], [subtitle] : Teks judul dan deskripsi peringatan (bisa dikustomisasi jika digunakan untuk transaksi lain).
///
/// ### ⚠️ Catatan Penting:
/// - Nilai selisih kekurangan saldo dihitung otomatis: `(totalAmount - currentBalance).clamp(0, totalAmount)`.
class KycInsufficientBalanceBottomSheet extends StatelessWidget {
  /// Callback saat tombol "Top Up Sekarang" ditekan.
  final VoidCallback? onTopup;

  /// Callback saat tombol "Batal" atau tombol close (X) ditekan.
  final VoidCallback? onCancel;

  /// Total nominal transaksi yang dibutuhkan (default: 25.000).
  final int totalAmount;

  /// Saldo Kompay yang tersedia saat ini.
  final int currentBalance;

  /// Judul modal (default: 'Saldo Tidak Mencukupi').
  final String title;

  /// Deskripsi modal.
  final String subtitle;

  /// Label baris total transaksi (default: 'Total Transaksi Equity').
  final String totalLabel;

  /// Label baris saldo tersedia (default: 'Saldo Kompay Tersedia').
  final String balanceLabel;

  /// Label baris kekurangan saldo (default: 'Kekurangan Saldo').
  final String shortageLabel;

  const KycInsufficientBalanceBottomSheet({
    super.key,
    this.onTopup,
    this.onCancel,
    this.totalAmount = 25000,
    this.currentBalance = 0,
    this.title = 'Saldo Tidak Mencukupi',
    this.subtitle =
        'Silakan lakukan pengisian saldo (Top Up) terlebih dahulu untuk melanjutkan transaksi equity ini.',
    this.totalLabel = 'Total Transaksi Equity',
    this.balanceLabel = 'Saldo Kompay Tersedia',
    this.shortageLabel = 'Kekurangan Saldo',
  });

  // ---------------------------------------------------------------------------
  // Static factory
  // ---------------------------------------------------------------------------

  /// Helper statis untuk menampilkan bottom sheet peringatan saldo tidak mencukupi.
  ///
  /// ```dart
  /// KycInsufficientBalanceBottomSheet.show(
  ///   context,
  ///   totalAmount: 25000,
  ///   currentBalance: 10000,
  ///   onTopup: () => openTopupPage(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onTopup,
    VoidCallback? onCancel,
    int totalAmount = 25000,
    int currentBalance = 0,
    String title = 'Saldo Tidak Mencukupi',
    String subtitle =
        'Silakan lakukan pengisian saldo (Top Up) terlebih dahulu untuk melanjutkan transaksi equity ini.',
    String totalLabel = 'Total Transaksi Equity',
    String balanceLabel = 'Saldo Kompay Tersedia',
    String shortageLabel = 'Kekurangan Saldo',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (_) => KycInsufficientBalanceBottomSheet(
        onTopup: onTopup,
        onCancel: onCancel ?? () => Navigator.pop(context),
        totalAmount: totalAmount,
        currentBalance: currentBalance,
        title: title,
        subtitle: subtitle,
        totalLabel: totalLabel,
        balanceLabel: balanceLabel,
        shortageLabel: shortageLabel,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final effectiveCancel = onCancel ?? () => Navigator.pop(context);
    final shortage = (totalAmount - currentBalance).clamp(0, totalAmount);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFDCDCDC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.pill),
            topRight: Radius.circular(AppRadius.pill),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.lg,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header: Title & Close Button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headingMd.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: effectiveCancel,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: const Color(0xFF737373),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Card Rincian Saldo (Putih Bersih di atas background #DCDCDC)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: Total Transaksi
                      _buildRowItem(
                        icon: SvgPicture.asset(
                          'assets/images/superapp/kyc/ic_cheklist_circle.svg',
                          width: 24,
                          height: 24,
                        ),
                        label: totalLabel,
                        labelColor: const Color(0xFF737373),
                        value: CurrencyFormat.convertToIdr(totalAmount, 0),
                        valueColor: const Color(0xFF0F172A),
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Saldo Kompay Tersedia
                      _buildRowItem(
                        icon: SvgPicture.asset(
                          'assets/images/superapp/kyc/ic_kompay_balance_popup.svg',
                          width: 24,
                          height: 24,
                        ),
                        label: balanceLabel,
                        labelColor: const Color(0xFF737373),
                        value: CurrencyFormat.convertToIdr(currentBalance, 0),
                        valueColor: const Color(0xFF0F172A),
                      ),
                      const SizedBox(height: 14),

                      // Row 3: Kekurangan Saldo (Merah)
                      _buildRowItem(
                        icon: SvgPicture.asset(
                          'assets/images/superapp/kyc/ic_insufficient_balance.svg',
                          width: 24,
                          height: 24,
                        ),
                        label: shortageLabel,
                        labelColor: const Color(0xFFEF4444),
                        value: CurrencyFormat.convertToIdr(shortage, 0),
                        valueColor: const Color(0xFFEF4444),
                        isShortage: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Tombol Batal
                TextButton(
                  onPressed: effectiveCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    minimumSize: const Size(double.infinity, AppSpacing.touchSm),
                  ),
                  child: Text(
                    'Batal',
                    style: AppTypography.bodyMdSemiBold.copyWith(
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // ── Tombol Top Up Sekarang
                DsButton(
                  text: 'Top Up Sekarang',
                  onPressed: () {
                    Navigator.pop(context);
                    if (onTopup != null) {
                      onTopup!();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowItem({
    required Widget icon,
    required String label,
    required Color labelColor,
    required String value,
    required Color valueColor,
    bool isShortage = false,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmRegular.copyWith(
              color: labelColor,
              fontWeight: isShortage ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyLgSemiBold.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
