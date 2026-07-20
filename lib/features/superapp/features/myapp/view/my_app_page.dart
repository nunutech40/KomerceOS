import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/widgets/custom_toast.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/features/superapp/features/authentication/widgets/verification_required_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/aplikasiku_bloc.dart';
import '../domain/entities/aplikasiku_entity.dart';
import '../widget/app_service_card.dart';
import '../widget/app_service_shimmer.dart';
import '../widget/app_status_chip.dart';

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  late AplikasikuBloc _aplikasikuBloc;

  @override
  void initState() {
    super.initState();
    _aplikasikuBloc = locator<AplikasikuBloc>();
    _aplikasikuBloc.add(FetchAplikasikuEvent());
  }

  @override
  void dispose() {
    _aplikasikuBloc.close();
    super.dispose();
  }

  static const Map<String, String> _descriptions = {
    'komship':
        'Kirim paket COD & non-COD, cairkan dana instan. Dapatkan diskon ongkir spesial.',
    'kompack':
        'Solusi pergudangan Jawa dan luar Jawa tanpa biaya sewa. Dari penyimpanan hingga pengiriman.',
    'komtim':
        'Tim E-commerce lengkap siap bantu kelola tokomu. Mulai dari CS, admin marketplace, hingga tim live.',
    'komchat': 'Platform chat commerce terintegrasi untuk tim sales kamu.',
    'komcards':
        'Buat kartu virtual tanpa batas untuk bayar iklan. Nikmati cashback dan bebas biaya admin.',
    'komform': 'Buat form order custom untuk toko online kamu.',
    'komplace':
        'Satu dashboard untuk semua toko di marketplacemu. Kelola pesanan, stok, dan chat pelanggan.',
    'komclass': 'Kelas online untuk tingkatkan skill jualanmu.',
    'pumkm': 'Pendampingan khusus untuk UMKM.',
    'komads': 'Layanan periklanan digital untuk maksimalkan penjualan.',
    'komed': 'Edukasi dan pelatihan dari ahlinya.',
  };

  Widget _buildLeading(AplikasiItemEntity item) {
    if (item.logoUrl.isNotEmpty) {
      if (item.logoUrl.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          item.logoUrl,
          width: 32,
          height: 32,
          placeholderBuilder: (context) => const Icon(Icons.image, size: 28),
        );
      } else {
        return CachedNetworkImage(
          imageUrl: item.logoUrl,
          width: 32,
          height: 32,
          placeholder: (context, url) => const Icon(Icons.image, size: 28),
          errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image, size: 28),
        );
      }
    }
    return const Icon(
      Icons.apps,
      color: Color(0xFF0C82DF),
      size: 28,
    );
  }

  Widget _buildTrailing(AplikasiItemEntity item, bool isResending) {
    if (item.active && !item.verified && !item.learnMore) {
      return AppStatusChip(
        text: isResending ? 'Mengirim...' : 'Kirim ulang Verifikasi',
        backgroundColor: const Color(0xFFFEF3E6),
        textColor: const Color(0xFFD84E0F),
      );
    } else if (item.active && item.verified) {
      return const AppStatusChip(
        text: 'Terdaftar',
        backgroundColor: Color(0xFFE2F9EB),
        textColor: Color(0xFF107C41),
      );
    } else {
      return const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textDark,
        size: 16,
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: _aplikasikuBloc,
        child: BlocListener<AplikasikuBloc, AplikasikuState>(
          listenWhen: (previous, current) {
            if (previous is AplikasikuLoaded && current is AplikasikuLoaded) {
              return previous.resendMessage != current.resendMessage &&
                  current.resendMessage != null;
            }
            return false;
          },
          listener: (context, state) {
            if (state is AplikasikuLoaded && state.resendMessage != null) {
              String message = state.resendMessage!;
              if (state.resendCountDown != null && state.resendCountDown! > 0) {
                message =
                    "Harap tunggu ${state.resendCountDown} detik untuk mengirim ulang.";
              }
              showToast(context, message);
            }
          },
          child: Scaffold(
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
                              border:
                                  Border.all(color: const Color(0xFFE5E5E5)),
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
                              border:
                                  Border.all(color: const Color(0xFFE5E5E5)),
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

                          // Service List from API
                          BlocBuilder<AplikasikuBloc, AplikasikuState>(
                            builder: (context, state) {
                              if (state is AplikasikuLoading) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 4, // Show 4 shimmers while loading
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 20),
                                  itemBuilder: (context, index) =>
                                      const AppServiceShimmer(),
                                );
                              } else if (state is AplikasikuError) {
                                return Center(child: Text(state.message));
                              } else if (state is AplikasikuLoaded) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.data.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 20),
                                  itemBuilder: (context, index) {
                                    final item = state.data[index];
                                    return AppServiceCard(
                                      leading: _buildLeading(item),
                                      title:
                                          item.key, // UI uses the key for title
                                      description: _descriptions[item.key] ??
                                          'Layanan dari Komerce.id',
                                      trailing: _buildTrailing(
                                          item, state.isResending),
                                      onTap: () {
                                        if (state.isResending) return;

                                        if (item.active &&
                                            !item.verified &&
                                            !item.learnMore) {
                                          final email = context
                                                  .read<SuperappProfileBloc>()
                                                  .state
                                                  .displayProfile
                                                  ?.email ??
                                              '';
                                          VerificationRequiredBottomSheet.show(
                                              context: context,
                                              email: email,
                                              partnerProducts: [
                                                PartnerProductModel(
                                                  id: 1, // Optional, can be any non-null for selection
                                                  productName: item.key,
                                                  isVerified: item.verified,
                                                  urlLogo: item.logoUrl,
                                                )
                                              ]);
                                        } else if (!item.active &&
                                            item.deepLink.isNotEmpty) {
                                          _launchUrl(item.deepLink);
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
