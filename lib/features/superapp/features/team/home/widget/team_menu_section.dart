import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_icon.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class TeamMenuSection extends StatelessWidget {
  final int invoiceBadgeCount;
  final int shoppingBadgeCount;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onShoppingTap;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onPerformanceTap;
  final VoidCallback? onTalentPoolTap;
  final VoidCallback? onListOfTeamTap;
  final String? accountStatus;

  const TeamMenuSection({
    Key? key,
    required this.invoiceBadgeCount,
    required this.shoppingBadgeCount,
    this.onInvoiceTap,
    this.onShoppingTap,
    this.onAttendanceTap,
    this.onPerformanceTap,
    this.onTalentPoolTap,
    this.onListOfTeamTap,
    this.accountStatus,
  }) : super(key: key);

  Widget _buildBadgedMenuIcon({
    required String title,
    required String iconAsset,
    required int badgeCount,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        DsMenuIcon(
          title: title,
          icon: Image.asset(iconAsset, width: 48, height: 48),
          onTap: isDisabled ? null : onTap,
          textColor: isDisabled ? AppColors.grey600 : null,
        ),
        if (badgeCount > 0)
          Positioned(
            right: 8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primaryBase,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: AppTypography.bodySmRegular.copyWith(
                    color: AppColors.alwaysWhite,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccountOff = accountStatus == 'off';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
        children: [
          _buildBadgedMenuIcon(
            title: 'Invoice',
            iconAsset: 'assets/images/team/ic_invoice.png',
            badgeCount: invoiceBadgeCount,
            onTap: onInvoiceTap,
          ),
          _buildBadgedMenuIcon(
            title: 'Belanja',
            iconAsset: isAccountOff 
                ? 'assets/images/team/ic_shopping_disable.png' 
                : 'assets/images/team/ic_shopping.png',
            badgeCount: shoppingBadgeCount,
            onTap: onShoppingTap,
            isDisabled: isAccountOff,
          ),
          _buildBadgedMenuIcon(
            title: 'Presensi',
            iconAsset: isAccountOff 
                ? 'assets/images/team/ic_presence_disable.png' 
                : 'assets/images/team/ic_presence.png',
            badgeCount: 0,
            onTap: onAttendanceTap,
            isDisabled: isAccountOff,
          ),
          _buildBadgedMenuIcon(
            title: 'Report\nPerforma', // Two lines based on slicing width
            iconAsset: isAccountOff 
                ? 'assets/images/team/ic_report_disable.png' 
                : 'assets/images/team/ic_report.png',
            badgeCount: 0,
            onTap: onPerformanceTap,
            isDisabled: isAccountOff,
          ),
          _buildBadgedMenuIcon(
            title: 'Talent Pool',
            iconAsset: isAccountOff 
                ? 'assets/images/team/ic_talent_pool_disable.png' 
                : 'assets/images/team/ic_talent_pool.png',
            badgeCount: 0,
            onTap: onTalentPoolTap,
            isDisabled: isAccountOff,
          ),
          DsMenuIcon(
            title: 'Daftar Tim',
            icon: const DsAppImage(
              source: 'assets/images/superapp/home/ic_list_team.svg',
              width: 48,
              height: 48,
            ),
            onTap: isAccountOff ? null : onListOfTeamTap,
            textColor: isAccountOff ? AppColors.grey600 : null,
          ),
        ],
      ),
    );
  }
}
