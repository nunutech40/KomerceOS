import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';

import '../widget/account_action_tile.dart';

class SettingPinPage extends StatelessWidget {
  const SettingPinPage({super.key});

  void _openFlow(BuildContext context, PinFlow flow) {
    final email =
        context.read<SuperappProfileBloc>().state.displayProfile?.email ?? '';
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PinFlowPage(flow: flow, email: email),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const DsAppBar(
          title: 'PIN',
          backgroundColor: AppColors.background,
          containerLeadingColor: AppColors.alwaysWhite,
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Material(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccountActionTile(
                  icon: Icons.person_search_outlined,
                  title: 'Lupa PIN',
                  subtitle: 'Atur ulang PIN kamu',
                  onTap: () => _openFlow(context, PinFlow.forgot),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                AccountActionTile(
                  icon: Icons.sync_outlined,
                  title: 'Ubah PIN',
                  subtitle: 'Buat PIN baru untuk keamanan akun',
                  onTap: () => _openFlow(context, PinFlow.change),
                ),
              ],
            ),
          ),
        ),
      );
}
