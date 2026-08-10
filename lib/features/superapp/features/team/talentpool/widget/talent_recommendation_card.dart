import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';

import '../talent_assets.dart';
import 'industry_tag.dart';

/// Kartu talent versi grid untuk data API [TalentRecommendationModel].
class TalentRecommendationGridCard extends StatelessWidget {
  final TalentRecommendationModel talent;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const TalentRecommendationGridCard({
    super.key,
    required this.talent,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto ──
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DsAppImage(
                    source: talent.photoUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Badge wishlist
                  // TODO: Enable wishlist badge when ready
                  /* Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: const BoxDecoration(
                          color: AppColors.alwaysWhite,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          talent.isWishlist
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: AppSpacing.iconSm,
                          color: talent.isWishlist
                              ? AppColors.errorBase
                              : AppColors.grey300,
                        ),
                      ),
                    ),
                  ), */
                ],
              ),
            ),

            // ── Detail ──
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talent.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmSemiBold
                        .copyWith(color: AppColors.grey800),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    talent.skillName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelXs
                        .copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Stats row
                  Row(
                    children: [
                      Flexible(
                        child: _StatBadge.cr(talent.closingRate),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: _StatBadge.rate(talent.rate.toDouble()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  // Experience + Industry
                  Row(
                    children: [
                      Flexible(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: AppTypography.labelXs
                                .copyWith(color: AppColors.grey700),
                            children: [
                              TextSpan(text: talent.experience),
                              if (talent.industryName.isNotEmpty) ...[
                                const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs),
                                    child: Icon(
                                      Icons.circle,
                                      size: 2,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ),
                                TextSpan(text: talent.industryName),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  // Wishlist count
                  // TODO: Enable wishlist count when ready
                  /* Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: AppSpacing.iconXs,
                        color: AppColors.errorBase,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          'Ditandai oleh ${talent.wishlistCount} partner lain',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelXs
                              .copyWith(color: AppColors.grey600),
                        ),
                      ),
                    ],
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu talent versi list untuk data API [TalentRecommendationModel].
class TalentRecommendationListCard extends StatelessWidget {
  final TalentRecommendationModel talent;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const TalentRecommendationListCard({
    super.key,
    required this.talent,
    this.onTap,
    this.onWishlistTap,
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
                    source: talent.photoUrl,
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
                        talent.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMdSemiBold
                            .copyWith(color: AppColors.grey800),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        talent.skillName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmRegular
                            .copyWith(color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Experience label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: AppSpacing.iconXs,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      talent.experience,
                      style: AppTypography.labelXs
                          .copyWith(color: AppColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md3),
            Row(
              children: [
                _StatBadge.cr(talent.closingRate),
                const SizedBox(width: AppSpacing.xs),
                _StatBadge.rate(talent.rate.toDouble()),
                if (talent.industryName.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Builder(builder: (context) {
                    final industries = talent.industryName
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                    final primaryIndustry =
                        industries.isNotEmpty ? industries.first : '';
                    final extraCount =
                        industries.length > 1 ? industries.length - 1 : 0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (primaryIndustry.isNotEmpty)
                          IndustryTag(label: primaryIndustry),
                        if (extraCount > 0) ...[
                          const SizedBox(width: AppSpacing.xs),
                          IndustryMoreTag(count: extraCount),
                        ],
                      ],
                    );
                  }),
                ],
              ],
            ),
            // TODO: Enable wishlist section when ready
            /* const SizedBox(height: AppSpacing.md3),
            const Divider(height: 1, color: AppColors.grey200),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                GestureDetector(
                  onTap: onWishlistTap,
                  child: Icon(
                    talent.isWishlist
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: AppSpacing.iconSm,
                    color: talent.isWishlist
                        ? AppColors.errorBase
                        : AppColors.grey300,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Ditandai oleh ${talent.wishlistCount} partner lain',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmRegular
                        .copyWith(color: AppColors.grey600),
                  ),
                ),
              ],
            ), */
          ],
        ),
      ),
    );
  }
}

/// Badge statistik (CR & Rate).
class _StatBadge extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color color;
  final Color background;

  const _StatBadge({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.background,
  });

  factory _StatBadge.cr(int value) => _StatBadge(
        iconAsset: TalentAssets.icTarget,
        label: 'CR $value%',
        color: AppColors.successBase,
        background: AppColors.successLight,
      );

  factory _StatBadge.rate(double value) => _StatBadge(
        iconAsset: TalentAssets.icStar,
        label: 'Rate $value',
        color: AppColors.warningBase,
        background: AppColors.warningLight,
      );

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
