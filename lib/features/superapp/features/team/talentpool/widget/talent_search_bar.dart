import 'package:flutter/material.dart';
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
