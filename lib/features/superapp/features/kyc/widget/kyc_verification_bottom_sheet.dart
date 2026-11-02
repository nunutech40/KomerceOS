import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_identity_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_insufficient_balance_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_payment_success_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/check_bill_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/topup_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// # KycVerificationBottomSheet
///
/// Bottom sheet utama untuk promosi, penawaran benefit, dan pembayaran biaya verifikasi KYC akun.
///
/// ### 📌 Kapan Digunakan:
/// - Dipicu ketika pengguna menekan tombol CTA "Ajukan Verifikasi KTP ↗" pada:
///   - Bagian Saldo / Header di `HomePage` (`BalanceSection`).
///   - Bagian Status Akun di `SettingPage` (`SettingKycStatusSection`).
/// - Menampilkan benefit akun terverifikasi, nominal biaya (Rp 25.000), dan melakukan validasi saldo Kompay secara otomatis.
///
/// ### 🔄 Alur & Keputusan Bisnis Internal:
/// 1. User menekan tombol "Ajukan Verifikasi".
/// 2. Widget memeriksa saldo Kompay pengguna via `locator<SuperappProfileBloc>()`:
///    - **Jika Saldo < Rp 25.000**:
///      Modal ini ditutup, lalu otomatis membuka [KycInsufficientBalanceBottomSheet]
///      yang menampilkan rincian kekurangan dana dan tombol langsung ke halaman Top Up.
///    - **Jika Saldo >= Rp 25.000**:
///      Tombol berubah ke state loading, lalu memanggil API pemotongan biaya KYC.
///      Setelah sukses, modal [KycPaymentSuccessBottomSheet] dimunculkan dan memicu callback [onSubmit].
///
/// ### 💻 Contoh Penggunaan:
/// ```dart
/// await KycVerificationBottomSheet.show(
///   context,
///   onSubmit: () {
///     // Navigasi ke panduan pengunggahan KTP atau form KYC
///     Navigator.pushNamed(context, '/kyc/identity');
///   },
///   onTopupTap: () {
///     // Opsional: custom routing ke halaman Top Up jika saldo kurang
///     Navigator.push(context, MaterialPageRoute(builder: (_) => const TopupPage()));
///   },
/// );
/// ```
///
/// ### ⚙️ Parameter:
/// - [context] : BuildContext dari layar pemanggil (disimpan sebagai `parentContext` untuk navigasi aman).
/// - [onSubmit] : Callback setelah pembayaran biaya verifikasi 25k berhasil.
/// - [onCancel] : Callback saat tombol "Batal" ditekan. Defaults ke `Navigator.pop`.
/// - [onTopupTap] : Callback kustom untuk aksi tombol Top Up jika saldo tidak cukup (default membuka `TopupPage`).
///
/// ### ⚠️ Catatan Penting:
/// - Widget ini bergantung pada dependency injection [locator] untuk `SuperappProfileBloc` dan `DioClient`.
class KycVerificationBottomSheet extends StatefulWidget {
  /// Context parent pemanggil (misal: HomePage / BalanceSection) untuk mencegah context unmounted.
  final BuildContext? parentContext;

  /// Callback saat proses pembayaran verifikasi sukses.
  final VoidCallback? onSubmit;

  /// Callback saat tombol "Batal" ditekan. Defaults ke [Navigator.pop].
  final VoidCallback? onCancel;

  /// Callback untuk navigasi ke alur Top Up jika saldo < 25.000.
  final VoidCallback? onTopupTap;

  const KycVerificationBottomSheet({
    super.key,
    this.parentContext,
    this.onSubmit,
    this.onCancel,
    this.onTopupTap,
  });

  // ---------------------------------------------------------------------------
  // Static factory
  // ---------------------------------------------------------------------------

  /// Helper statis untuk menampilkan bottom sheet penawaran & pembayaran verifikasi KYC.
  ///
  /// ```dart
  /// KycVerificationBottomSheet.show(
  ///   context,
  ///   onSubmit: () => navigateToKycForm(),
  /// );
  /// ```
  static Future<T?> show<T>(
    BuildContext context, {
    VoidCallback? onSubmit,
    VoidCallback? onCancel,
    VoidCallback? onTopupTap,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      builder: (sheetContext) => KycVerificationBottomSheet(
        parentContext: context,
        onSubmit: onSubmit,
        onCancel: onCancel ?? () => Navigator.pop(sheetContext),
        onTopupTap: onTopupTap,
      ),
    );
  }

  @override
  State<KycVerificationBottomSheet> createState() =>
      _KycVerificationBottomSheetState();
}

class _KycVerificationBottomSheetState
    extends State<KycVerificationBottomSheet> {
  DsButtonState _buttonState = DsButtonState.enabled;

  /// Validasi saldo sebelum memproses verifikasi
  Future<void> _handleAjukanVerifikasi() async {
    if (_buttonState == DsButtonState.loading) return;

    final safeContext = widget.parentContext ?? context;
    final onTopupCallback = widget.onTopupTap;
    final onSubmitCallback = widget.onSubmit;

    // 1. Dapatkan saldo terkini (prioritas dari SuperappProfileBloc)
    final profileBloc = locator<SuperappProfileBloc>();
    int? currentSaldo = profileBloc.state.displayProfile?.saldo;

    // Fallback jika belum ter-cache di BLoC
    if (currentSaldo == null) {
      try {
        final repo = locator<SuperappProfileRepositoryImpl>();
        final result = await repo.getProfile();
        result.fold(
          (failure) {},
          (profile) => currentSaldo = profile.saldo,
        );
      } catch (_) {}
    }

    final int saldo = currentSaldo ?? 0;
    debugPrint('[KYC] Pengecekan saldo sebelum verifikasi: Rp $saldo');

    if (!mounted) return;

    // KASUS 1: Saldo < Rp 25.000
    // Tombol TIDAK loading, tutup sheet verifikasi, lalu tampilkan pop-up Saldo Tidak Mencukupi
    if (saldo < 25000) {
      Navigator.pop(context);

      KycInsufficientBalanceBottomSheet.show(
        safeContext,
        totalAmount: 25000,
        currentBalance: saldo,
        onTopup: () {
          debugPrint('[KYC] onTopup ditekan di KycInsufficientBalanceBottomSheet');
          if (onTopupCallback != null) {
            onTopupCallback();
          } else {
            try {
              safeContext
                  .read<CheckBillBloc>()
                  .add(const FetchCheckBillEvent(isFromKyc: true));
            } catch (e) {
              debugPrint('[KYC] Error dispatch CheckBillBloc: $e');
              Navigator.push(
                safeContext,
                MaterialPageRoute(
                  builder: (_) => const TopupPage(isFromKyc: true),
                ),
              );
            }
          }
        },
      );
      return;
    }

    // KASUS 2: Saldo >= Rp 25.000
    // Tombol loading, hit API pembayaran verifikasi KTP
    setState(() {
      _buttonState = DsButtonState.loading;
    });

    final navigator = Navigator.of(safeContext);
    final scaffoldMessenger = ScaffoldMessenger.of(safeContext);

    try {
      final dioClient = locator<DioClient>();
      debugPrint('[KYC] Hit API pay verification: ${Endpoints.payKtpVerification}');

      final response = await dioClient.post(Endpoints.payKtpVerification);
      debugPrint('[KYC] Response pay verification: ${response.statusCode} => ${response.data}');

      final isSuccess = response.statusCode == 200 ||
          (response.data is Map &&
              response.data['meta']?['status'] == 'success');

      if (!isSuccess) {
        throw Exception(
          response.data is Map && response.data['meta']?['message'] != null
              ? response.data['meta']['message']
              : 'Gagal melakukan pembayaran verifikasi.',
        );
      }

      if (!mounted) return;

      // Reset state tombol sebelum sheet di-pop
      setState(() {
        _buttonState = DsButtonState.enabled;
      });

      // 1. Tutup sheet promosi verifikasi akun
      Navigator.pop(context);

      // 2. Refresh profil superapp di background (potong saldo ter-reflect di BLoC & UI)
      try {
        locator<SuperappProfileRepositoryImpl>().notifyProfileRefresh();
        safeContext
            .read<SuperappProfileBloc>()
            .add(const FetchSuperappProfileEvent());
      } catch (e) {
        debugPrint('[KYC] Trigger profile refresh error: $e');
      }

      // 3. Tampilkan popup "Pembayaran Berhasil" dengan tombol "Oke".
      // Saat tombol "Oke" ditekan user, tombol berubah loading "Redirecting...",
      // lalu otomatis membuka popup "Verifikasi Identitas Kamu".
      KycPaymentSuccessBottomSheet.show(
        safeContext,
        buttonText: 'Oke',
        onAction: () {
          if (navigator.mounted) {
            KycIdentityBottomSheet.show(
              safeContext,
              onSubmit: onSubmitCallback,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('[KYC] Error saat memproses verifikasi: $e');
      if (mounted) {
        setState(() {
          _buttonState = DsButtonState.enabled;
        });
      }

      String errorMessage = 'Gagal melakukan verifikasi. Silakan coba lagi.';
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['meta']?['message'] != null) {
          errorMessage = resData['meta']['message'].toString();
        } else if (resData is Map && resData['message'] != null) {
          errorMessage = resData['message'].toString();
        }
      } else if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorBase,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl2),
            topRight: Radius.circular(AppRadius.xl2),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl2),
            topRight: Radius.circular(AppRadius.xl2),
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Stack(
                children: [
                  // ── Background Diam/Fixed: Gradien biru tetap di atas (tidak ikut scroll)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 460,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF2398F0),
                                Color(0xFF4CB5F9),
                                Color(0xFF7DCAF9),
                                Color(0xFFB4E1FC),
                                Color(0xFFE4F3FD),
                                AppColors.alwaysWhite,
                              ],
                              stops: [0.0, 0.28, 0.52, 0.72, 0.88, 1.0],
                            ),
                          ),
                        ),
                        // Dotted Grid Pattern yang memudar lembut (fade-out) ke bawah
                        const Positioned.fill(
                          child: CustomPaint(
                            painter: _DotGridPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Foreground Content: Bisa di-scroll tanpa menggeser background
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.insetLg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ikon perisai
                        Image.asset(
                          'assets/images/superapp/kyc/ic_perisai.png',
                          width: 104,
                          height: 104,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Judul
                        Text(
                          'Verifikasi Akun',
                          style: AppTypography.headingMd.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Verifikasi sekali untuk seumur hidup',
                          style: AppTypography.bodyMdRegular.copyWith(
                            color: const Color(0xFF4A5568),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Harga
                        Text(
                          'Hanya Rp 25.000',
                          style: AppTypography.headingLg.copyWith(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // White card: daftar benefit
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.insetLg),
                          decoration: BoxDecoration(
                            color: AppColors.alwaysWhite,
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const _BenefitsList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Batal button
                        TextButton(
                          onPressed: _buttonState == DsButtonState.loading
                              ? null
                              : (widget.onCancel ?? () => Navigator.pop(context)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBase,
                            textStyle: AppTypography.bodyMdSemiBold,
                            minimumSize: const Size(
                              double.infinity,
                              AppSpacing.touchSm,
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Ajukan Verifikasi button
                        DsButton(
                          text: 'Ajukan Verifikasi',
                          state: _buttonState,
                          onPressed: _handleAjukanVerifikasi,
                        ),
                      ],
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

// =============================================================================
// _DotGridPainter
//
// Dekorasi titik-titik putih rapi (grid) di atas background gradien biru.
// Titik-titik memudar (fade-out opacity) secara halus ke arah bawah.
// =============================================================================

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 18.0;
    const dotRadius = 1.5;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      // Calculate opacity fade based on vertical position
      // Dots fade out smoothly as they approach the card
      final double progress = (y / size.height).clamp(0.0, 1.0);
      final double opacity = (0.35 * (1.0 - progress)).clamp(0.0, 1.0);
      if (opacity <= 0.01) continue;

      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// _BenefitsList
//
// 6 item keuntungan verifikasi akun, sesuai desain.
// =============================================================================

class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  static const List<_BenefitData> _benefits = [
    _BenefitData(
      title: 'Request Pickup Semua Ekspedisi Komship',
      description:
          'Tinggal request, kurir datang jemput dan paket langsung dikirim,',
      url: 'https://komship.id',
    ),
    _BenefitData(
      title: 'Gratis 5 Kartu Komcards',
      description:
          'Kamu bisa melakukan penambahan akun di platform iklan yang sama,',
      url: 'https://komcards.id',
    ),
    _BenefitData(
      title: 'Kemudahan Penambahan Akun Whitelisted Komads',
      description:
          'Kamu bisa melakukan penambahan akun di platform iklan yang sama,',
      url: 'https://komads.id',
    ),
    _BenefitData(
      title: 'Akun Lebih Terpercaya',
      description: 'Mengurangi risiko pemblokiran dan kendala operasional',
    ),
    _BenefitData(
      title: 'Verifikasi 1x untuk semua kebutuhan',
      description: 'Lebih praktis saat menggunakan berbagai fitur dan produk',
    ),
    _BenefitData(
      title: 'Akses Fitur & Produk Komerce',
      description:
          'Mendapatkan akses penuh ke Fitur & Produk Komerce di kemudian hari',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _benefits.map((item) => _BenefitRow(item: item)).toList(),
    );
  }
}

/// Data model per benefit item (private, hanya untuk internal widget ini).
class _BenefitData {
  final String title;
  final String description;
  final String? url;

  bool get hasLink => url != null && url!.isNotEmpty;

  const _BenefitData({
    required this.title,
    required this.description,
    this.url,
  });
}

// =============================================================================
// _BenefitRow
//
// Satu baris benefit: ikon ceklis hijau + teks judul + deskripsi + link opsional
// =============================================================================

class _BenefitRow extends StatelessWidget {
  final _BenefitData item;

  const _BenefitRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon ceklis hijau (bulat)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.successBase,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.alwaysWhite,
              size: 14,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMdSemiBold.copyWith(
                    color: AppColors.black0A0A,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                _DescriptionText(
                  description: item.description,
                  url: item.url,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _DescriptionText
//
// Deskripsi abu-abu dengan opsional "Selengkapnya" (link orange) di akhir.
// =============================================================================

class _DescriptionText extends StatelessWidget {
  final String description;
  final String? url;

  const _DescriptionText({
    required this.description,
    this.url,
  });

  bool get hasLink => url != null && url!.isNotEmpty;

  Future<void> _handleTap() async {
    if (url != null && url!.isNotEmpty) {
      final uri = Uri.parse(url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final descStyle = AppTypography.bodySmRegular.copyWith(
      color: AppColors.textDark,
    );

    if (!hasLink) {
      return Text(description, style: descStyle);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$description ', style: descStyle),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: _handleTap,
              child: Text(
                'Selengkapnya',
                style: AppTypography.bodySmMedium.copyWith(
                  color: AppColors.primaryBase,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
