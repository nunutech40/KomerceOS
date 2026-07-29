import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_info_balance.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_item.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_skeleton.dart';

/// Section balance — Kompay saldo, Kompoint, tombol Top Up & Penarikan,
/// serta card Pending Balance (khusus Komship verified).
class BalanceSection extends StatelessWidget {
  const BalanceSection({super.key, required this.onTopupTap});

  final VoidCallback onTopupTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Kompay saldo + Kompoint
              Expanded(child: _KompayInfo()),
              // Right: Tombol Top Up + Penarikan
              _ActionButtons(onTopupTap: onTopupTap),
            ],
          ),
          // Card Pending Balance — hanya tampil jika Komship verified
          _PendingBalanceCard(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _KompayInfo
// ---------------------------------------------------------------------------

class _KompayInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuperappProfileBloc, SuperappProfileState>(
      buildWhen: (prev, curr) =>
          prev.displaySaldo != curr.displaySaldo ||
          prev.displayKompoints != curr.displayKompoints ||
          prev.isBalanceLoading != curr.isBalanceLoading ||
          prev.isBalanceError != curr.isBalanceError,
      builder: (context, profileState) {
        return Padding(
          padding: const EdgeInsets.only(left: 8, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kompay',
                style: AppTypography.bodyMdRegular
                    .copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: AppSpacing.xxs),
              // Saldo: shimmer → error → nilai
              if (profileState.isBalanceLoading)
                const ShimmerBox(width: 140, height: 24, borderRadius: 6)
              else if (profileState.isBalanceError)
                GestureDetector(
                  onTap: () => context
                      .read<SuperappProfileBloc>()
                      .add(const FetchSuperappProfileEvent()),
                  child: Row(
                    children: [
                      Text(
                        '-- ',
                        style: AppTypography.numericXl.copyWith(
                          color: AppColors.grey350,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(Icons.refresh_rounded,
                          size: 18, color: AppColors.primaryBase),
                    ],
                  ),
                )
              else
                Text(
                  CurrencyFormat.convertToIdr(
                      profileState.displaySaldo ?? 0, 0),
                  style: AppTypography.numericXl.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs2),
              Row(
                children: [
                  Text(
                    'Kompoint',
                    style: AppTypography.bodyMdRegular
                        .copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SvgPicture.asset(
                    'assets/images/ic_kompoint.svg',
                    width: 16.0,
                    height: 16.0,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${profileState.displayKompoints ?? 0}',
                    style: AppTypography.bodySmSemiBold
                        .copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _ActionButtons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onTopupTap});
  final VoidCallback onTopupTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsMenuItem(
          title: 'Top Up',
          icon: SvgPicture.asset(
              'assets/images/superapp/home/ic_plus.svg'),
          onTap: onTopupTap,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs2,
            vertical: AppSpacing.xs,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DsMenuItem(
          title: 'Penarikan',
          icon: SvgPicture.asset(
              'assets/images/superapp/home/ic_withdraw.svg'),
          onTap: () {},
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs2,
            vertical: AppSpacing.xs,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _PendingBalanceCard
// ---------------------------------------------------------------------------

class _PendingBalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hanya tampil jika Komship verified
    return BlocSelector<SuperappProfileBloc, SuperappProfileState, bool>(
      selector: (state) => state.isKomshipVerified,
      builder: (context, isKomship) {
        if (!isKomship) return const SizedBox.shrink();

        return BlocBuilder<BalanceSummaryBloc, BalanceSummaryState>(
          builder: (context, balanceState) {
            String formatNominal(num value) {
              if (value == 0) return 'Rp 0';
              if (value % 1 == 0) {
                return CurrencyFormat.convertToIdrNum(value, 0);
              }
              return CurrencyFormat.convertToIdrNum(value, 2);
            }

            if (balanceState is BalanceSummaryError) {
              return Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  AppInfoCard(
                    backgroundColor: AppColors.bgLight,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gagal memuat saldo pending',
                            style: AppTypography.bodyMdRegular
                                .copyWith(color: AppColors.textDark),
                          ),
                          GestureDetector(
                            onTap: () {
                              final profile = context
                                  .read<SuperappProfileBloc>()
                                  .state
                                  .displayProfile;
                              if (profile?.id != null) {
                                context.read<BalanceSummaryBloc>().add(
                                      FetchBalanceSummaryEvent(
                                          profile!.id.toString()),
                                    );
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.refresh_rounded,
                                    size: 16, color: AppColors.primaryBase),
                                const SizedBox(width: 4),
                                Text(
                                  'Coba lagi',
                                  style: AppTypography.bodySmSemiBold
                                      .copyWith(color: AppColors.primaryBase),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }

            if (balanceState is BalanceSummaryInitial ||
                balanceState is BalanceSummaryLoading) {
              return const Column(
                children: [
                  SizedBox(height: AppSpacing.lg),
                  AppInfoCard(
                    backgroundColor: AppColors.bgLight,
                    children: [
                      ShimmerBox(width: 180, height: 16),
                      SizedBox(height: AppSpacing.xs),
                      ShimmerBox(width: 220, height: 16),
                    ],
                  ),
                ],
              );
            }

            if (balanceState is! BalanceSummaryLoaded) {
              return const SizedBox.shrink();
            }

            final pendingBalance =
                formatNominal(balanceState.data.pendingBalance ?? 0);
            final pendingProblem =
                formatNominal(balanceState.data.pendingBalanceOnProblem ?? 0);

            return Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                AppInfoCard(
                  backgroundColor: AppColors.bgLight,
                  children: [
                    HighlightText(
                      prefix: 'Saldo Pending : ',
                      highlight: pendingBalance,
                      style: AppTypography.bodyMdRegular
                          .copyWith(color: AppColors.textDark),
                      highlightStyle: AppTypography.bodyMdBold
                          .copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    HighlightText(
                      prefix: 'Dari nilai tersebut, ',
                      highlight: pendingProblem,
                      suffix: ',- nya perlu dimonitor',
                      style: AppTypography.bodyMdRegular
                          .copyWith(color: AppColors.textDark),
                      highlightStyle: AppTypography.bodyMdSemiBold
                          .copyWith(color: AppColors.primaryBase),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
