import 'package:flutter/material.dart';
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
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.grey400,
                  size: AppSpacing.iconLg,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md3,
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
          icon: Icons.tune_rounded,
          onTap: onFilterTap,
        ),
        const SizedBox(width: AppSpacing.sm),
        _ViewToggle(
          isGridView: isGridView,
          onChanged: onViewChanged,
        ),
      ],
    );
  }
}

/// Tombol kotak dengan border untuk aksi filter.
class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Icon(icon, color: AppColors.grey700, size: AppSpacing.iconMd),
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
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          _ToggleSegment(
            icon: Icons.grid_view_rounded,
            isActive: isGridView,
            onTap: () => onChanged(true),
          ),
          _ToggleSegment(
            icon: Icons.view_agenda_outlined,
            isActive: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md3),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBase : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md3),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iconMd,
          color: isActive ? AppColors.alwaysWhite : AppColors.grey400,
        ),
      ),
    );
  }
}
