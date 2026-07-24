import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';

import '../../../../../common/global/design_system/app_typography.dart';
import 'home_skeleton.dart'; 

/// 1. Enum State yang Saling Eksklusif [cite: 333]
enum PartnerType {
  regular,
  komship,
}

class DsHomeHeader extends StatelessWidget {
  final PartnerType type;

  // Data eksplisit yang turun dari parent [cite: 306]
  final String partnerName;
  final String? savingsAmount; // Contoh: "Rp 2.205.976"
  final String? profileUrl;

  /// Widget notifikasi di-inject dari luar agar rebuild notif
  /// tidak mempengaruhi rebuild header & balance.
  final Widget notificationWidget;

  const DsHomeHeader({
    super.key,
    required this.type,
    this.partnerName = 'Partner',
    this.savingsAmount,
    this.profileUrl,
    required this.notificationWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Sebaiknya gunakan AppSpacing.md
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: App Icon
          _buildProfileAvatar(),
          
          const SizedBox(width: 12),

          // Tengah: Greeting Variant
          Expanded(
            child: _buildGreetingContent(),
          ),

          const SizedBox(width: 12),

          // Kanan: Notification Icon (di-inject dari luar)
          notificationWidget,
        ],
      ),
    );
  }

/// Helper widget untuk mengatur logika rendering avatar sesuai kondisi urlprofile
  Widget _buildProfileAvatar() {
    // KONDISI A: Jika urlprofile ADA (tidak null) dan tidak kosong
    if (profileUrl != null && profileUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20), // Radius 20 agar melingkar sempurna pada ukuran 40x40
        child: Container(
          width: 40,
          height: 40,
          color: const Color(0xFFFFF0E6), // Background sementara saat loading (Token: Orange50)
          child: Image.network(
            profileUrl!,
            fit: BoxFit.cover,
            // Defensive Programming: Jika link URL rusak/error, otomatis tampilkan default asset kamu
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAsset();
            },
            // Menampilkan loading indikator mikro saat gambar sedang di-download
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD63B00)),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // KONDISI B: Jika urlprofile TIDAK ADA (null atau string kosong ""), pakai asset default kamu
    return _buildDefaultAsset();
  }

 Widget _buildDefaultAsset() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.transparent, // AppColors.transparent
      ),
      child: SvgPicture.asset('assets/images/superapp/home/ic_komerce_os.svg'),
    );
  }

  Widget _buildGreetingContent() {
    // Evaluasi visual state berdasarkan enum
    switch (type) {
      case PartnerType.komship:
        return Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D9),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🚚'), // Ganti dgn Svg asset truk jika ada
                const SizedBox(width: 6),
                Text(
                  'Hemat Ongkir ',
                  style: AppTypography.bodyMdRegular.copyWith(color: Colors.black),
                ),
                if (savingsAmount == null)
                  const ShimmerBox(width: 80, height: 16)
                else
                  Text(
                    savingsAmount!,
                    style: AppTypography.headingXxs,
                  ),
              ],
            ),
          ),
        );
      case PartnerType.regular:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: AppTypography.bodyMdRegular.copyWith(color: AppColors.textDark),
                children: [
                  const TextSpan(text: 'Hallo '),
                  TextSpan(
                    text: partnerName,
                    style: AppTypography.headingXxs.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Selamat datang di KomerceOS',
              style: AppTypography.bodySmRegular.copyWith(color: AppColors.textDark)
            ),
          ],
        );
    }
  }

}