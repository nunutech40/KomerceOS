import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../widget/app_service_card.dart';
import '../widget/app_status_chip.dart';

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.alwaysWhite,
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF222222),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Aplikasiku',
                    style: AppTypography.headingSm.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Top Featured Card: Komerce.id
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.alwaysWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon Container
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.bgLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/superapp/ic_logo_komerce.png',
                                width: 32,
                                height: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Komerce.id',
                            style: AppTypography.headingSm.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Semua environmet yang kamu butuhkan ada di sini',
                            style: AppTypography.bodyMdRegular.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service List
                    // 1. komship
                    AppServiceCard(
                      //leading bisa ambil dari response
                      leading: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFFF1B404),
                        size: 28,
                      ),
                      title: 'komship',
                      description: 'Kirim paket COD & non-COD, cairkan dana instan. Dapatkan diskon ongkir spesial.',
                      trailing: const AppStatusChip(
                        text: 'Terdaftar',
                        backgroundColor: Color(0xFFE2F9EB),
                        textColor: Color(0xFF107C41),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // 2. kompack
                    AppServiceCard(
                      leading: const Icon(
                        Icons.storefront_outlined,
                        color: Color(0xFF0C82DF),
                        size: 28,
                      ),
                      title: 'kompack',
                      description: 'Solusi pergudangan Jawa dan luar Jawa tanpa biaya sewa. Dari penyimpanan hingga pengiriman.',
                      trailing: const AppStatusChip(
                        text: 'Terdaftar',
                        backgroundColor: Color(0xFFE2F9EB),
                        textColor: Color(0xFF107C41),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // 3. komcards
                    AppServiceCard(
                      leading: const Icon(
                        Icons.credit_card_rounded,
                        color: Color(0xFF6E6E6E),
                        size: 28,
                      ),
                      title: 'komcards',
                      description: 'Buat kartu virtual tanpa batas untuk bayar iklan. Nikmati cashback dan bebas biaya admin.',
                      trailing: const AppStatusChip(
                        text: 'Kirim ulang Verifikasi',
                        backgroundColor: Color(0xFFFEF3E6),
                        textColor: Color(0xFFD84E0F),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // 4. komtim
                    AppServiceCard(
                      leading: const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFF1CB15A),
                        size: 28,
                      ),
                      title: 'komtim',
                      description: 'Tim E-commerce lengkap siap bantu kelola tokomu. Mulai dari CS, admin marketplace, hingga tim live.',
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textDark,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),

                    // 5. komplace
                    AppServiceCard(
                      leading: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Color(0xFFF95E16),
                        size: 26,
                      ),
                      title: 'komplace',
                      description: 'Satu dashboard untuk semua toko di marketplacemu. Kelola pesanan, stok, dan chat pelanggan.',
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textDark,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
