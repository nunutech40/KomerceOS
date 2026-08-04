import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Badge kecil dengan ikon + teks untuk statistik talent
/// (mis. "CR 80%" dan "Rate 4.5").
///
/// Dipakai baik di kartu grid maupun list.
class TalentStatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const TalentStatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  /// Badge conversion rate (hijau).
  factory TalentStatBadge.conversionRate(int value) {
    return TalentStatBadge(
      icon: Icons.autorenew_rounded,
      label: 'CR $value%',
      color: AppColors.successBase,
      background: AppColors.successLight,
    );
  }

  /// Badge rating (oranye).
  factory TalentStatBadge.rating(double value) {
    return TalentStatBadge(
      icon: Icons.star_rounded,
      label: 'Rate $value',
      color: AppColors.warningBase,
      background: AppColors.warningLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconXs, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelXsMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
