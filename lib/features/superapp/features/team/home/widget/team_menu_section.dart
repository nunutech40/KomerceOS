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
  }) : super(key: key);

  Widget _buildBadgedMenuIcon({
    required String title,
    required String iconAsset,
    required int badgeCount,
    VoidCallback? onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        DsMenuIcon(
          title: title,
          icon: Image.asset(iconAsset, width: 48, height: 48),
          onTap: onTap,
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
            iconAsset: 'assets/images/team/ic_shopping.png',
            badgeCount: shoppingBadgeCount,
            onTap: onShoppingTap,
          ),
          _buildBadgedMenuIcon(
            title: 'Presensi',
            iconAsset: 'assets/images/team/ic_presence.png',
            badgeCount: 0,
            onTap: onAttendanceTap,
          ),
          _buildBadgedMenuIcon(
            title: 'Report\nPerforma', // Two lines based on slicing width
            iconAsset: 'assets/images/team/ic_report.png',
            badgeCount: 0,
            onTap: onPerformanceTap,
          ),
          _buildBadgedMenuIcon(
            title: 'Talent Pool',
            iconAsset: 'assets/images/team/ic_talent_pool.png',
            badgeCount: 0,
            onTap: onTalentPoolTap,
          ),
          DsMenuIcon(
            title: 'Daftar Tim',
            icon: const DsAppImage(
              source: 'assets/images/superapp/home/ic_list_team.svg',
              width: 48,
              height: 48,
            ),
            onTap: onListOfTeamTap,
          ),
        ],
      ),
    );
  }
}
