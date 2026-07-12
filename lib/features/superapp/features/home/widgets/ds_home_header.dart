import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';

import '../../../../../common/global/design_system/app_typography.dart';
// Asumsikan kamu mengimpor token Design System di sini
// import '../design_system.dart'; 

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
  final int notificationCount;
  final String? profileUrl;
  
  // Event naik ke atas sebagai callback [cite: 306]
  final VoidCallback onNotificationPressed;

  const DsHomeHeader({
    super.key,
    required this.type,
    this.partnerName = 'Partner',
    this.savingsAmount,
    this.notificationCount = 0,
    required this.onNotificationPressed,
    this.profileUrl,
  }) : assert(
         type != PartnerType.komship || savingsAmount != null,
         'savingsAmount wajib diisi jika PartnerType adalah komship',
       );

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

          // Kanan: Notification Icon dengan Badge
          GestureDetector(
            onTap: onNotificationPressed,
            child: _buildNotificationIcon(),
          ),
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
                Text(
                  savingsAmount ?? '',
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

  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lingkaran abu-abu dasar
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.bgLight,
            shape: BoxShape.circle,
          ),
          child: Center(child: SvgPicture.asset('assets/images/superapp/home/ic_notification.svg',width: 20,height: 20)),
        ),
        
        // Badge merah dinamis (hanya muncul jika ada notif)
        if (notificationCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD7EAF6), width: 1),
                color: AppColors.primaryBase,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  // Jika > 99, tampilkan '99+'
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: AppTypography.headingSm.copyWith(color: Colors.white,fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}