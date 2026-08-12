import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../model/talent_model.dart';
import '../talent_assets.dart';
import 'industry_tag.dart';
import 'talent_stat_badge.dart';

/// Kartu talent versi grid: foto besar di atas, detail di bawah.
class TalentGridCard extends StatelessWidget {
  final TalentModel talent;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const TalentGridCard({
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
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Photo(talent: talent, onFavoriteTap: onFavoriteTap),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmSemiBold.copyWith(
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    talent.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelXs.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Flexible(
                        child: TalentStatBadge.conversionRate(
                          talent.conversionRate,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: TalentStatBadge.rating(talent.rating),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          talent.experience,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelXs.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                      if (talent.primaryIndustry.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.xs),
                        IndustryTag(label: talent.primaryIndustry),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs2),
                  _MarkedByPartner(count: talent.markedByPartner),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  final TalentModel talent;
  final VoidCallback? onFavoriteTap;

  const _Photo({required this.talent, this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DsAppImage(
            source: talent.avatarUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _FavoriteButton(
              isFavorite: talent.isFavorite,
              onTap: onFavoriteTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.circular),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.alwaysWhite,
          shape: BoxShape.circle,
        ),
        child: isFavorite
            ? const DsAppImage(
                source: TalentAssets.icHeart,
                width: AppSpacing.iconSm,
                height: AppSpacing.iconSm,
              )
            : const Icon(
                Icons.favorite_border_rounded,
                size: AppSpacing.iconSm,
                color: AppColors.grey400,
              ),
      ),
    );
  }
}

/// Baris "Ditandai oleh N partner lain".
class _MarkedByPartner extends StatelessWidget {
  final int count;

  const _MarkedByPartner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DsAppImage(
          source: TalentAssets.icHeart,
          width: AppSpacing.iconXs,
          height: AppSpacing.iconXs,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'Ditandai oleh $count partner lain',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelXs.copyWith(color: AppColors.grey600),
          ),
        ),
      ],
    );
  }
}
