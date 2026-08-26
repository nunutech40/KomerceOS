import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Baris pencarian pada halaman Daftar Tim: input "Cari nama atau email"
/// dan tombol filter opsional di sebelah kanan.
///
/// Tombol filter hanya muncul bila [onFilterTap] diisi; biarkan `null`
/// untuk menyembunyikannya.
class TeamSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const TeamSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final onFilterTap = this.onFilterTap;
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
                hintText: 'Cari nama atau email',
                hintStyle: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.grey400,
                ),
                suffixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.grey400,
                  size: AppSpacing.iconLg,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md3,
                  horizontal: AppSpacing.md,
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
        if (onFilterTap != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _SquareIconButton(
            icon: Icons.tune_rounded,
            onTap: onFilterTap,
          ),
        ],
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
