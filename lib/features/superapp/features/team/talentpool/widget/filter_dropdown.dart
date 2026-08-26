import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Dropdown expandable untuk sheet filter.
///
/// Menampilkan label, kotak nilai terpilih, dan daftar opsi yang bisa
/// dibuka/tutup di bawahnya (inline, sesuai desain filter Talent Pool).
class FilterDropdown extends StatefulWidget {
  final String label;
  final String value;
  final String? hint;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool _expanded = false;

  bool get _isPlaceholder =>
      widget.hint != null && widget.value == widget.hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.bodyMdMedium.copyWith(color: AppColors.grey800),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md3,
            ),
            decoration: BoxDecoration(
              color: AppColors.alwaysWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value,
                    style: AppTypography.bodyMdRegular.copyWith(
                      color: _isPlaceholder
                          ? AppColors.grey400
                          : AppColors.grey800,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey600,
                  size: AppSpacing.iconLg,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: AppColors.alwaysWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.grey200),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = option == widget.value;
                return InkWell(
                  onTap: () {
                    widget.onChanged(option);
                    setState(() => _expanded = false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md3,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: AppTypography.bodyMdRegular.copyWith(
                              color: isSelected
                                  ? AppColors.primaryBase
                                  : AppColors.grey700,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: AppSpacing.iconMd,
                            color: AppColors.primaryBase,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
