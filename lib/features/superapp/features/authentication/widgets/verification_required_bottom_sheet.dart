import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/domain/entities/partner_product_model.dart';
import 'package:komtim_partner/features/superapp/features/authentication/bloc/verification_bloc.dart';
import 'package:komtim_partner/features/superapp/features/authentication/views/email_verif_sent_page.dart';

// -----------------------------------------------------------------------------
// VerificationRequiredBottomSheet
//
// Ditampilkan ketika check-login mengembalikan allowed_login == false.
// User memilih salah satu produk yang belum terverifikasi menggunakan
// radio button, lalu menekan tombol untuk mengirim ulang email verifikasi.
// -----------------------------------------------------------------------------

class VerificationRequiredBottomSheet extends StatelessWidget {
  final String email;
  final List<PartnerProductModel> partnerProducts;

  const VerificationRequiredBottomSheet({
    super.key,
    required this.email,
    required this.partnerProducts,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String email,
    required List<PartnerProductModel> partnerProducts,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (_) => BlocProvider<VerificationBloc>(
        create: (context) {
          final bloc = locator<VerificationBloc>();
          if (partnerProducts.isNotEmpty) {
            bloc.add(VerificationProductSelected(partnerProducts.first));
          }
          return bloc;
        },
        child: VerificationRequiredBottomSheet(
          email: email,
          partnerProducts: partnerProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          left: AppSpacing.pageMargin2xs,
          right: AppSpacing.pageMargin2xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.xl),
            topRight: Radius.circular(AppRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.insetLg,
              AppSpacing.xl,
              AppSpacing.insetLg,
              AppSpacing.insetLg,
            ),
            child: BlocConsumer<VerificationBloc, VerificationState>(
              listener: _onStateChanged,
              builder: (context, state) {
                final isLoading = state.status == VerificationStatus.loading;
                final selectedId = state.selectedProduct?.id;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Title Row with Close Button ---
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Verifikasi Email',
                            textAlign: TextAlign.center,
                            style: AppTypography.headingMd.copyWith(
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 20, color: AppColors.grey800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // --- Description ---
                    Text(
                      'Beberapa produk belum terverifikasi.\nPilih produk yang ingin kamu verifikasi terlebih dahulu.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Product List ─────────────────────────────────────

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < partnerProducts.length; i++) ...[
                            _ProductRadioTile(
                              product: partnerProducts[i],
                              selectedId: selectedId,
                              onTap: () {
                                context.read<VerificationBloc>().add(
                                      VerificationProductSelected(
                                          partnerProducts[i]),
                                    );
                              },
                            ),
                            if (i < partnerProducts.length - 1)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.grey200,
                              ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // --- Secondary text button (Kembali) ---

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorBase,
                        textStyle: AppTypography.bodyMdMedium,
                        minimumSize:
                            const Size(double.infinity, AppSpacing.touchSm),
                      ),
                      child: const Text('Kembali'),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // --- Primary action button ---
                    DsButton(
                      text: 'Verifikasi',
                      state: isLoading
                          ? DsButtonState.loading
                          : (selectedId != null
                              ? DsButtonState.enabled
                              : DsButtonState.disabled),
                      onPressed: () {
                        context.read<VerificationBloc>().add(
                              VerificationEmailSent(email: email),
                            );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, VerificationState state) {
    if (state.status == VerificationStatus.success) {
      final productName = state.selectedProduct?.productName ?? '';
      Navigator.pop(context); // Tutup bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<VerificationBloc>(
            create: (_) => locator<VerificationBloc>(),
            child: EmailVerifSentPage(
              email: email,
              productName: productName,
            ),
          ),
        ),
      );
    } else if (state.status == VerificationStatus.rateLimited &&
        state.countDown > 0) {
      // Rate limited → tetap arahkan ke halaman verifikasi dengan countdown
      final productName = state.selectedProduct?.productName ?? '';
      Navigator.pop(context); // Tutup bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<VerificationBloc>(
            create: (_) => locator<VerificationBloc>(),
            child: EmailVerifSentPage(
              email: email,
              productName: productName,
              initialCountDown: state.countDown,
            ),
          ),
        ),
      );
    } else if (state.status == VerificationStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.errorBase,
          ),
        );
      context.read<VerificationBloc>().add(const VerificationResetStatus());
    }
  }
}

// -----------------------------------------------------------------------------
// _ProductRadioTile
// Widget untuk setiap baris produk dengan logo + nama + radio button
// -----------------------------------------------------------------------------

class _ProductRadioTile extends StatelessWidget {
  final PartnerProductModel product;
  final int? selectedId;
  final VoidCallback onTap;

  const _ProductRadioTile({
    required this.product,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: product.urlLogo != null && product.urlLogo!.isNotEmpty
                    ? (product.urlLogo!.toLowerCase().endsWith('.svg')
                        ? SvgPicture.network(
                            product.urlLogo!,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          )
                        : CachedNetworkImage(
                            imageUrl: product.urlLogo!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.store_outlined,
                              size: 20,
                              color: AppColors.grey400,
                            ),
                          ))
                    : const Icon(
                        Icons.store_outlined,
                        size: 20,
                        color: AppColors.grey400,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Product Name
            Expanded(
              child: Text(
                product.productName ?? '-',
                style: AppTypography.bodyMdSemiBold.copyWith(
                  color: AppColors.grey800,
                ),
              ),
            ),

            // Radio
            Radio<int?>(
              value: product.id,
              groupValue: selectedId,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryBase,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
