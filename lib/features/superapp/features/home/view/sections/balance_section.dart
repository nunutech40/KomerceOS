import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_bottom_sheet.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_info_balance.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_item.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/core/domain/usecases/check_pin_setting_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/verify_pin_use_case.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_skeleton.dart';
import 'package:komtim_partner/features/superapp/features/kyc/flow/kyc_resume_flow.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_status_badge.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_success_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_verification_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';
import 'package:komtim_partner/features/superapp/features/pin/bloc/account_pin_cubit.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/bank_account_pin_sheet.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/repositories/bank_account_repository.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/bank_account_page.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/withdrawal_no_bank_sheet.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/withdrawal_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/check_bill_bloc.dart';

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

class _ActionButtons extends StatefulWidget {
  const _ActionButtons({required this.onTopupTap});
  final VoidCallback onTopupTap;

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _openingWithdrawal = false;

  Future<void> _checkWithdrawalPin() async {
    while (mounted) {
      bool hasPin;
      try {
        final result = await di.locator<CheckPinSettingUseCase>().execute();
        hasPin = result.fold(
          (failure) => throw StateError(failure.message),
          (data) => data.isExist,
        );
      } catch (_) {
        if (!mounted) return;
        final retry = await DsBottomSheet.show<bool>(
          context: context,
          title: 'Oops, Terjadi Kesalahan',
          description: 'Status PIN belum dapat diperiksa. Silakan coba lagi.',
          primaryButtonText: 'Coba Lagi',
          onPrimaryPressed: () => Navigator.of(context).pop(true),
          secondaryButtonText: 'Kembali',
          onSecondaryPressed: () => Navigator.of(context).pop(false),
        );
        if (retry == true) continue;
        return;
      }

      if (!mounted) return;
      if (!hasPin) {
        await _promptCreatePin();
      } else {
        await _verifyWithdrawalPin();
      }
      return;
    }
  }

  Future<void> _verifyWithdrawalPin() async {
    final pinCubit = di.locator<AccountPinCubit>();
    final remaining = await pinCubit.attemptLeft();
    await pinCubit.close();
    if (!mounted) return;
    final canContinue = remaining.fold<bool>(
      (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        return false;
      },
      (count) => count > 0,
    );
    if (!canContinue) return;

    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BankAccountPinSheet(
        onVerify: (pin) async {
          final result = await di.locator<VerifyPinUseCase>().execute(pin);
          return result.fold(
            (failure) {
              final message = failure.message;
              final match =
                  RegExp(r'Sisa percobaan:\s*(\d+)', caseSensitive: false)
                      .firstMatch(message);
              final locked = RegExp(r'lock:\s*(true|1)', caseSensitive: false)
                  .hasMatch(message);
              if (match == null && !locked) throw StateError(message);
              return BankPinVerificationResult(
                isValid: false,
                attemptsLeft: int.tryParse(match?.group(1) ?? ''),
                locked: locked,
              );
            },
            (data) => BankPinVerificationResult(
              isValid: data.isValid,
              attemptsLeft: data.isValid ? null : data.attemptLeft,
            ),
          );
        },
        onForgotPin: () {
          Navigator.of(context).pop(false);
          final email =
              context.read<SuperappProfileBloc>().state.displayProfile?.email ??
                  '';
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => PinFlowPage(flow: PinFlow.forgot, email: email),
          ));
        },
        onLocked: () {
          if (!mounted) return;
          context
              .read<SuperappProfileBloc>()
              .add(const ClearSuperappProfileEvent());
          context.read<AuthBloc>().add(const AuthLogoutRequested());
        },
      ),
    );
    if (!mounted || verified != true) return;
    await _openWithdrawalAfterPin();
  }

  Future<void> _openWithdrawalAfterPin({bool promptNoBank = true}) async {
    while (mounted) {
      bool hasBank;
      try {
        final result = await di.locator<BankAccountRepository>().accounts();
        hasBank = result.fold(
          (failure) => throw StateError(failure.message),
          (accounts) => accounts.isNotEmpty,
        );
      } catch (_) {
        if (!mounted) return;
        final retry = await DsBottomSheet.show<bool>(
          context: context,
          title: 'Oops, Terjadi Kesalahan',
          description:
              'Daftar rekening belum dapat diperiksa. Silakan coba lagi.',
          primaryButtonText: 'Coba Lagi',
          onPrimaryPressed: () => Navigator.of(context).pop(true),
          secondaryButtonText: 'Kembali',
          onSecondaryPressed: () => Navigator.of(context).pop(false),
        );
        if (retry == true) continue;
        return;
      }

      if (!mounted) return;
      if (hasBank) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const WithdrawalPage(),
        ));
        return;
      }
      if (!promptNoBank) return;
      final add = await WithdrawalNoBankSheet.show(context);
      if (!mounted || add != true) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const BankAccountPage(),
      ));
      if (!mounted) return;
      promptNoBank = false;
    }
  }

  Future<void> _promptCreatePin() async {
    final createPin = await DsBottomSheet.show<bool>(
      context: context,
      title: 'Kamu Belum Membuat PIN',
      titleStyle: AppTypography.headingXs,
      description:
          'PIN digunakan untuk melindungi akun kamu.\nYuk buat sekarang',
      image: SvgPicture.asset(
        'assets/images/superapp/team/ilustration_forgot_pin.svg',
        width: 359,
        height: 326,
      ),
      secondaryButtonText: 'Kembali',
      secondaryButtonColor: AppColors.errorBase,
      onSecondaryPressed: () => Navigator.of(context).pop(false),
      primaryButtonText: 'Buat PIN',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
    );
    if (!mounted || createPin != true) return;

    final email =
        context.read<SuperappProfileBloc>().state.displayProfile?.email ?? '';
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PinFlowPage(flow: PinFlow.create, email: email),
    ));
  }

  Future<void> _handleWithdrawalTap() async {
    if (_openingWithdrawal) return;
    _openingWithdrawal = true;
    try {
      await _handleWithdrawalTapOnce();
    } finally {
      _openingWithdrawal = false;
    }
  }

  Future<void> _handleWithdrawalTapOnce() async {
    final profileBloc = context.read<SuperappProfileBloc>();
    final profileState = profileBloc.state;
    final rawStatus = profileState.displayProfile?.verificationKtpStatus;
    if (rawStatus == null) {
      profileBloc.add(const FetchSuperappProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status verifikasi akun belum dimuat. Coba lagi.'),
      ));
      return;
    }
    final status = KycKtpStatus.fromValue(rawStatus);

    debugPrint(
        '[KYC] Tombol Penarikan ditekan, verification_ktp_status: $rawStatus');

    switch (status) {
      case KycKtpStatus.unverified:
        await KycVerificationBottomSheet.show<void>(
          context,
          onTopupTap: () {
            debugPrint(
                '[KYC] onTopupTap dipanggil dari KYC flow -> dispatch FetchCheckBillEvent(isFromKyc: true)');
            context
                .read<CheckBillBloc>()
                .add(const FetchCheckBillEvent(isFromKyc: true));
          },
        );
        break;
      case KycKtpStatus.paid:
      case KycKtpStatus.rejected:
        // Sama seperti Pengaturan: lanjutkan riwayat KYC tanpa membayar ulang.
        await KycResumeFlow.openFromSettings(context);
        break;
      case KycKtpStatus.inProgress:
        // Dalam proses verifikasi admin
        await KycSuccessBottomSheet.showVerificationInProgress(context);
        break;
      case KycKtpStatus.verified:
        // User terverifikasi KYC
        await _checkWithdrawalPin();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DsMenuItem(
          title: 'Top Up',
          icon: SvgPicture.asset('assets/images/superapp/home/ic_plus.svg'),
          onTap: widget.onTopupTap,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs2,
            vertical: AppSpacing.xs,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DsMenuItem(
          title: 'Penarikan',
          icon: SvgPicture.asset('assets/images/superapp/home/ic_withdraw.svg'),
          onTap: _handleWithdrawalTap,
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
