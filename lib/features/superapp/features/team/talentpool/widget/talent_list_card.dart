import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../model/talent_model.dart';
import 'industry_tag.dart';
import 'talent_stat_badge.dart';

/// Kartu talent versi list: avatar di kiri, detail di kanan.
class TalentListCard extends StatelessWidget {
  final TalentModel talent;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const TalentListCard({
    super.key,
    required this.talent,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md3),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: DsAppImage(
                    source: talent.avatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        talent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMdSemiBold.copyWith(
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        talent.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmRegular.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ExperienceLabel(experience: talent.experience),
              ],
            ),
            const SizedBox(height: AppSpacing.md3),
            Row(
              children: [
                TalentStatBadge.conversionRate(talent.conversionRate),
                const SizedBox(width: AppSpacing.xs),
                TalentStatBadge.rating(talent.rating),
                if (talent.primaryIndustry.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IndustryTag(label: talent.primaryIndustry),
                ],
                if (talent.extraIndustryCount > 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IndustryMoreTag(count: talent.extraIndustryCount),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md3),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: AppSpacing.iconSm,
                  color: AppColors.errorBase,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Ditandai oleh ${talent.markedByPartner} partner lain',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmRegular.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  onTap: onFavoriteTap,
                  child: Icon(
                    talent.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: AppSpacing.iconMd,
                    color:
                        talent.isFavorite ? AppColors.errorBase : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Label pengalaman dengan ikon jam di pojok kanan atas kartu.
class _ExperienceLabel extends StatelessWidget {
  final String experience;

  const _ExperienceLabel({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: AppSpacing.iconXs,
          color: AppColors.grey600,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          experience,
          style: AppTypography.labelXs.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}
