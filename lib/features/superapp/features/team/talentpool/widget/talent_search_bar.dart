import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_search_field.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_square_icon_button.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_view_toggle.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Baris pencarian pada Talent Pool: input "Cari talent",
/// tombol filter, dan toggle tampilan grid/list.
class TalentSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  const TalentSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.isGridView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.bodyMdRegular.copyWith(
                color: AppColors.grey800,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.alwaysWhite,
                hintText: 'Cari talent',
                hintStyle: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.grey400,
                ),
                suffixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.grey400,
                  size: AppSpacing.iconLg,
                ),
                contentPadding: const EdgeInsets.only(
                  top: AppSpacing.md3,
                  bottom: AppSpacing.md3,
                  left: AppSpacing.md3,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primaryBase),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SquareIconButton(
          onTap: onFilterTap,
        ),
        const SizedBox(width: AppSpacing.sm),
        DsViewToggle(isGridView: isGridView, onChanged: onViewChanged),
      ],
    );
  }
}

/// Tombol kotak dengan border untuk aksi filter.
class _SquareIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SquareIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md2),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.md2),
          border: Border.all(color: AppColors.grey200),
        ),
        child: const Center(
          child: DsAppImage(
            source: 'assets/images/superapp/ic_filter.svg',
            width: AppSpacing.iconMd,
            height: AppSpacing.iconMd,
          ),
        ),
      ),
    );
  }
}

/// Toggle grid/list dalam satu container tersegment.
class _ViewToggle extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isGridView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grayF5F5,
        borderRadius: BorderRadius.circular(AppRadius.md2),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            activeAsset: 'assets/images/superapp/ic_grid_active.png',
            inactiveAsset: 'assets/images/superapp/ic_grid_not_active.png',
            isActive: isGridView,
            onTap: () => onChanged(true),
          ),
          _ToggleSegment(
            activeAsset: 'assets/images/superapp/ic_list_active.png',
            inactiveAsset: 'assets/images/superapp/ic_list_no_active.png',
            isActive: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String activeAsset;
  final String inactiveAsset;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.activeAsset,
    required this.inactiveAsset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md3),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.alwaysWhite : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md3),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.grey400.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: DsAppImage(
          source: isActive ? activeAsset : inactiveAsset,
          width: AppSpacing.iconMd,
          height: AppSpacing.iconMd,
        ),
      ),
    );
  }
}
