import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';

import '../widget/account_action_tile.dart';
import 'setting_pin_page.dart';
import 'setting_profile_page.dart';
import 'bank_account_page.dart';

class SettingAccountPage extends StatefulWidget {
  const SettingAccountPage({super.key});

  @override
  State<SettingAccountPage> createState() => _SettingAccountPageState();
}

class _SettingAccountPageState extends State<SettingAccountPage> {
  bool _hasPinInCurrentUiSession = false;

  Future<void> _openPin() async {
    if (_hasPinInCurrentUiSession) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => const SettingPinPage(),
      ));
      return;
    }
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
    if (!mounted || createPin != true) return;
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
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const BankAccountPage(),
                  )),
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
