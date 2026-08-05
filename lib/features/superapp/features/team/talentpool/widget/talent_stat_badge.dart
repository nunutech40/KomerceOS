import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../talent_assets.dart';

/// Badge kecil dengan ikon + teks untuk statistik talent
/// (mis. "CR 80%" dan "Rate 4.5").
///
/// Dipakai baik di kartu grid maupun list.
class TalentStatBadge extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color color;
  final Color background;

  const TalentStatBadge({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.background,
  });

  /// Badge conversion rate (hijau).
  factory TalentStatBadge.conversionRate(int value) {
    return TalentStatBadge(
      iconAsset: TalentAssets.icTarget,
      label: 'CR $value%',
      color: AppColors.successBase,
      background: AppColors.successLight,
    );
  }

  /// Badge rating (oranye).
  factory TalentStatBadge.rating(double value) {
    return TalentStatBadge(
      iconAsset: TalentAssets.icStar,
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
          DsAppImage(
            source: iconAsset,
            width: AppSpacing.iconXs,
            height: AppSpacing.iconXs,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelXsMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
