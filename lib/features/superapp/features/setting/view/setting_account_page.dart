import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/core/domain/usecases/verify_pin_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/check_pin_setting_use_case.dart';
import 'package:komtim_partner/features/superapp/features/pin/bloc/account_pin_cubit.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';

import '../widget/account_action_tile.dart';
import '../widget/bank_account_pin_sheet.dart';
import 'setting_pin_page.dart';
import 'setting_profile_page.dart';
import 'bank_account_page.dart';

class SettingAccountPage extends StatefulWidget {
  const SettingAccountPage({super.key, this.checkPinExists});

  final Future<bool> Function()? checkPinExists;

  @override
  State<SettingAccountPage> createState() => _SettingAccountPageState();
}

class _SettingAccountPageState extends State<SettingAccountPage> {
  bool _hasPinInCurrentUiSession = false;
  bool _checkingBankPin = false;

  Future<void> _openBankAccounts() async {
    if (_checkingBankPin) return;
    if (!_hasPinInCurrentUiSession) {
      setState(() => _checkingBankPin = true);
      try {
        final exists = widget.checkPinExists == null
            ? await _checkPinExistsFromApi()
            : await widget.checkPinExists!();
        if (!mounted) return;
        if (!exists && !await _promptCreatePin()) return;
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
        if (retry == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openBankAccounts();
          });
        }
        return;
      } finally {
        if (mounted) setState(() => _checkingBankPin = false);
      }
    }
    if (!mounted) return;
    if (widget.checkPinExists == null) {
      final pinCubit = di.locator<AccountPinCubit>();
      final remaining = await pinCubit.attemptLeft();
      await pinCubit.close();
      if (!mounted) return;
      final canContinue = remaining.fold<bool>(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)));
          return false;
        },
        (count) => count > 0,
      );
      if (!canContinue) {
        if (remaining.isRight()) await _showBankPinLock();
        return;
      }
    }
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
              final remaining =
                  RegExp(r'Sisa percobaan:\s*(\d+)', caseSensitive: false)
                      .firstMatch(message);
              final locked = RegExp(r'lock:\s*(true|1)', caseSensitive: false)
                  .hasMatch(message);
              if (remaining == null && !locked) throw StateError(message);
              return BankPinVerificationResult(
                isValid: false,
                attemptsLeft: int.tryParse(remaining?.group(1) ?? ''),
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
        onLocked: () => _showBankPinLock(autoLogout: true),
      ),
    );
    if (!mounted || verified != true) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const BankAccountPage(),
    ));
  }

  Future<bool> _checkPinExistsFromApi() async {
    final result = await di.locator<CheckPinSettingUseCase>().execute();
    return result.fold(
      (failure) => throw StateError(failure.message),
      (data) => data.isExist,
    );
  }

  Future<void> _showBankPinLock({bool autoLogout = false}) async {
    if (!mounted) return;
    await DsBottomSheet.show<void>(
      context: context,
      isDismissible: !autoLogout,
      title: 'Terlalu Banyak Percobaan PIN',
      titleStyle: AppTypography.headingXs,
      description: 'Kamu telah mencapai batas maksimal percobaan PIN.\n'
          'Demi keamanan akun, silakan coba kembali\ndalam 24 jam.',
      image: const SizedBox(
        height: 208,
        child: Center(
          child: Icon(Icons.laptop_mac_rounded,
              size: 170, color: AppColors.primaryBase),
        ),
      ),
      secondaryButtonText: autoLogout ? null : 'Kembali',
      secondaryButtonColor: AppColors.primaryBase,
      onSecondaryPressed: () => Navigator.of(context).pop(),
      primaryButtonText: autoLogout ? 'Masuk Kembali' : 'Reset PIN',
      barrierColor: const Color(0x66000000),
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        if (autoLogout) {
          context.read<SuperappProfileBloc>().add(const ClearSuperappProfileEvent());
          context.read<AuthBloc>().add(AuthLogoutRequested());
          return;
        }
        final email =
            context.read<SuperappProfileBloc>().state.displayProfile?.email ??
                '';
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => PinFlowPage(flow: PinFlow.forgot, email: email),
        ));
      },
    );
  }

  Future<void> _openPin() async {
    bool hasPin;
    try {
      hasPin = widget.checkPinExists == null
          ? await _checkPinExistsFromApi()
          : await widget.checkPinExists!();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Status PIN belum dapat diperiksa. Coba lagi.')));
      return;
    }
    if (!mounted) return;
    if (hasPin) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const SettingPinPage(),
      ));
      return;
    }
    await _promptCreatePin();
  }

  Future<bool> _promptCreatePin() async {
    final createPin = await DsBottomSheet.show<bool>(
      context: context,
      title: 'Kamu Belum Membuat PIN',
      titleStyle: AppTypography.headingXs,
      description:
          'PIN digunakan untuk melindungi akun kamu.\nYuk buat sekarang',
      image: SvgPicture.asset(
        'assets/images/ilustrated-setpin.svg',
        width: 237,
        height: 218,
      ),
      secondaryButtonText: 'Kembali',
      secondaryButtonColor: AppColors.errorBase,
      onSecondaryPressed: () => Navigator.of(context).pop(false),
      primaryButtonText: 'Buat PIN',
      onPrimaryPressed: () => Navigator.of(context).pop(true),
    );
    if (!mounted || createPin != true) return false;
    final email =
        context.read<SuperappProfileBloc>().state.displayProfile?.email ?? '';
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PinFlowPage(
        flow: PinFlow.create,
        email: email,
        onCompleted: () {
          if (mounted) setState(() => _hasPinInCurrentUiSession = true);
        },
      ),
    ));
    return mounted && _hasPinInCurrentUiSession;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<SuperappProfileBloc>().state.displayProfile;
    final photoUrl = profile?.photoProfileUrl;
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DsAppBar(
        title: 'Informasi Akun',
        backgroundColor: AppColors.background,
        containerLeadingColor: AppColors.alwaysWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Material(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(16),
            elevation: 1,
            shadowColor: AppColors.grey300,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const SettingProfilePage(),
              )),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.background,
                      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                      child: hasPhoto
                          ? null
                          : const Icon(Icons.person_outline,
                              color: AppColors.grey600),
                    ),
                    const SizedBox(width: AppSpacing.md3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.fullName ?? '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyMdMedium),
                          Text('Profile Akun & Profile Bisnis',
                              style: AppTypography.bodySmRegular
                                  .copyWith(color: AppColors.grey600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.chevron_right,
                        size: AppSpacing.iconMd, color: AppColors.alwaysBlack),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(16),
            elevation: 1,
            shadowColor: AppColors.grey300,
            child: Column(
              children: [
                AccountActionTile(
                  icon: Icons.lock_outline,
                  title: 'PIN',
                  subtitle: 'PIN digunakan untuk melindungi akun kamu',
                  onTap: _openPin,
                ),
                const Divider(
                    height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                AccountActionTile(
                  icon: Icons.account_balance_outlined,
                  leadingWidget: SvgPicture.asset(
                    'assets/images/superapp/ic_bank.svg',
                    width: AppSpacing.iconLg,
                    height: AppSpacing.iconLg,
                  ),
                  title: 'Rekening Bank',
                  subtitle: 'Kelola rekening bank kamu',
                  onTap: _openBankAccounts,
                ),
                const Divider(
                    height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                const AccountActionTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'Ubah Password',
                  subtitle: 'Belum tersedia di Superapp',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
