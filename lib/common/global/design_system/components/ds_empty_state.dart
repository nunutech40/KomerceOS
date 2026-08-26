import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Widget empty state global yang dapat digunakan di seluruh fitur.
///
/// Menampilkan ilustrasi SVG, judul, dan deskripsi yang dapat dikustomisasi.
///
/// Contoh penggunaan (dengan dua kondisi):
/// ```dart
/// DsEmptyState(
///   imagePath: 'assets/images/team/empty_state_feed.svg',
///   title: isSearch ? 'Data tidak ditemukan' : 'Belum ada data',
///   description: isSearch
///       ? 'Coba kata kunci lain.'
///       : 'Tidak ada data tersedia saat ini.',
/// )
/// ```
class DsEmptyState extends StatelessWidget {
  /// Path asset SVG/PNG untuk ilustrasi.
  final String imagePath;

  /// Judul utama yang ditampilkan di bawah ilustrasi.
  final String title;

  /// Teks deskripsi pendukung di bawah judul.
  final String description;

  /// Lebar ilustrasi. Default: 200.
  final double imageWidth;

  /// Tinggi ilustrasi. Default: 200.
  final double imageHeight;

  const DsEmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.imageWidth = 200,
    this.imageHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsAppImage(
              source: imagePath,
              width: imageWidth,
              height: imageHeight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLgSemiBold
                  .copyWith(color: AppColors.black0A0A),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMdRegular
                  .copyWith(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget error state global yang dapat digunakan di seluruh fitur.
///
/// Menampilkan ikon error, judul, pesan error, dan tombol retry.
///
/// Contoh penggunaan:
/// ```dart
/// DsErrorState(
///   message: state.message,
///   onRetry: () => context.read<MyBloc>().add(FetchEvent()),
/// )
/// ```
class DsErrorState extends StatelessWidget {
  /// Pesan error yang ditampilkan kepada pengguna.
  final String message;

  /// Callback saat tombol "Coba Lagi" ditekan.
  final VoidCallback onRetry;

  /// Judul error. Default: 'Gagal memuat data'.
  final String title;

  /// Label tombol retry. Default: 'Coba Lagi'.
  final String retryLabel;

  const DsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Gagal memuat data',
    this.retryLabel = 'Coba Lagi',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: AppSpacing.iconXxl,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodyLgSemiBold
                  .copyWith(color: AppColors.grey700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmRegular
                  .copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: AppSpacing.lg),
            DsButton(text: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
