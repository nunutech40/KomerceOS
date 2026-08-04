import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../model/talent_filter.dart';
import 'filter_dropdown.dart';

/// Bottom sheet filter Talent Pool: Role, Industri, dan Urutkan.
///
/// Mengembalikan [TalentFilter] baru lewat `Navigator.pop` saat
/// "Terapkan Filter" ditekan. Menekan "Reset Filter" mengembalikan
/// filter ke nilai default.
class TalentFilterSheet extends StatefulWidget {
  final TalentFilter initialFilter;

  const TalentFilterSheet({super.key, required this.initialFilter});

  static Future<TalentFilter?> show(
    BuildContext context, {
    required TalentFilter initialFilter,
  }) {
    return showModalBottomSheet<TalentFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.alwaysWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) => TalentFilterSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<TalentFilterSheet> createState() => _TalentFilterSheetState();
}

class _TalentFilterSheetState extends State<TalentFilterSheet> {
  late String _role = widget.initialFilter.role;
  late String _industry = widget.initialFilter.industry;
  late String _sort = widget.initialFilter.sort;

  void _reset() {
    setState(() {
      _role = TalentFilterOptions.defaultRole;
      _industry = TalentFilterOptions.defaultIndustry;
      _sort = TalentFilterOptions.defaultSort;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      TalentFilter(role: _role, industry: _industry, sort: _sort),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md3,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DragHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Filter',
              style: AppTypography.headingXs.copyWith(color: AppColors.grey800),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterDropdown(
              label: 'Role',
              value: _role,
              options: TalentFilterOptions.roles,
              onChanged: (value) => setState(() => _role = value),
            ),
            const SizedBox(height: AppSpacing.md),
            FilterDropdown(
              label: 'Industri',
              value: _industry,
              options: TalentFilterOptions.industries,
              onChanged: (value) => setState(() => _industry = value),
            ),
            const SizedBox(height: AppSpacing.md),
            FilterDropdown(
              label: 'Urutkan',
              value: _sort,
              hint: TalentFilterOptions.defaultSort,
              options: TalentFilterOptions.sorts,
              onChanged: (value) => setState(() => _sort = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: _ResetButton(onTap: _reset)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: DsButton(text: 'Terapkan Filter', onPressed: _apply),
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

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
      ),
    );
  }
}

/// Tombol outline "Reset Filter".
class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBase,
          side: const BorderSide(color: AppColors.primaryBase),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
        child: Text(
          'Reset Filter',
          style: AppTypography.headingXxs.copyWith(
            color: AppColors.primaryBase,
          ),
        ),
      ),
    );
  }
}
