import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/services/connectivity_service.dart';

// -----------------------------------------------------------------------------
// NoInternetPage
//
// Widget full-screen yang ditampilkan ketika koneksi internet terputus.
// Ditampilkan sebagai overlay di atas semua halaman via ConnectivityWrapper (Stack),
// sehingga tidak mengganggu GoRouter navigation stack.
//
// Tombol "Coba Lagi" memicu pengecekan internet ulang secara manual.
// Jika internet kembali, ConnectivityWrapper akan menghilangkan overlay ini.
// -----------------------------------------------------------------------------

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        // Gunakan Material sebagai root agar text styling, ink, dsb tetap bekerja.
        // Tidak perlu Scaffold karena ini bukan route — ini overlay widget.
        color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMarginLg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/superapp/auth/not_have_internet.png',
                  width: 240,
                  height: 240,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Gagal mengambil data',
                  style: AppTypography.headingMd
                      .copyWith(color: AppColors.grey800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Data tidak dapat tampil, cek kembali internet kamu',
                  style: AppTypography.bodyMdRegular
                      .copyWith(color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl2),
                SizedBox(
                  width: 140,
                  child: DsButton(
                    text: 'Coba Lagi',
                    onPressed: () {
                      // Secara manual trigger pengecekan internet aktif
                      ConnectivityService().forceCheck();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
