import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';
import 'package:komtim_partner/features/superapp/features/team/talentpool/bloc/business_sector_bloc.dart';
import '../model/talent_filter.dart';

/// Bottom sheet filter Talent Pool bergaya checkbox multi-select.
///
/// Section: Bintang, Pengalaman, Industri (dari API via [BusinessSectorBloc]).
/// Mengembalikan [TalentFilter] baru lewat `Navigator.pop`.
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
      builder: (_) => BlocProvider.value(
        value: context.read<BusinessSectorBloc>(),
        child: TalentFilterSheet(initialFilter: initialFilter),
      ),
    );
  }

  @override
  State<TalentFilterSheet> createState() => _TalentFilterSheetState();
}

class _TalentFilterSheetState extends State<TalentFilterSheet> {
  late Set<int> _selectedRatings;
  late Set<String> _selectedExperiences;
  late Set<int> _selectedBusinessSectorIds;

  @override
  void initState() {
    super.initState();
    _selectedRatings = Set.of(widget.initialFilter.selectedRatings);
    _selectedExperiences = Set.of(widget.initialFilter.selectedExperiences);
    _selectedBusinessSectorIds =
        Set.of(widget.initialFilter.selectedBusinessSectorIds);
  }

  void _reset() {
    setState(() {
      _selectedRatings = {};
      _selectedExperiences = {};
      _selectedBusinessSectorIds = {};
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      TalentFilter(
        selectedRatings: _selectedRatings,
        selectedExperiences: _selectedExperiences,
        selectedBusinessSectorIds: _selectedBusinessSectorIds,
      ),
    );
  }

  void _toggleRating(int rating) {
    setState(() {
      if (_selectedRatings.contains(rating)) {
        _selectedRatings.remove(rating);
      } else {
        _selectedRatings.add(rating);
      }
    });
  }

  void _toggleExperience(String value) {
    setState(() {
      if (_selectedExperiences.contains(value)) {
        _selectedExperiences.remove(value);
      } else {
        _selectedExperiences.add(value);
      }
    });
  }

  void _toggleSector(int id) {
    setState(() {
      if (_selectedBusinessSectorIds.contains(id)) {
        _selectedBusinessSectorIds.remove(id);
      } else {
        _selectedBusinessSectorIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header sticky
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md3,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                children: [
                  const _DragHandle(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by',
                        style: AppTypography.headingXs
                            .copyWith(color: AppColors.grey800),
                      ),
                      TextButton(
                        onPressed: _reset,
                        child: Text(
                          'Reset',
                          style: AppTypography.bodyMdSemiBold
                              .copyWith(color: AppColors.primaryBase),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.grey100),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // ── Bintang ──
                  _FilterSection(
                    title: 'Bintang',
                    children: TalentFilterOptions.ratings.map((star) {
                      final isSelected = _selectedRatings.contains(star);
                      return _CheckboxItem(
                        isSelected: isSelected,
                        onTap: () => _toggleRating(star),
                        label: Row(
                          children: [
                            Text(
                              '$star',
                              style: AppTypography.bodyMdRegular.copyWith(
                                color: isSelected
                                    ? AppColors.primaryBase
                                    : AppColors.grey700,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(
                              Icons.star_rounded,
                              size: AppSpacing.iconSm,
                              color: Color(0xFFF5A623),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Pengalaman ──
                  _FilterSection(
                    title: 'Pengalaman',
                    children: TalentFilterOptions.experiences.map((opt) {
                      final isSelected = _selectedExperiences.contains(opt.value);
                      return _CheckboxItem(
                        isSelected: isSelected,
                        onTap: () => _toggleExperience(opt.value),
                        label: Text(
                          opt.label,
                          style: AppTypography.bodyMdRegular.copyWith(
                            color: isSelected
                                ? AppColors.primaryBase
                                : AppColors.grey700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Industri ──
                  _FilterSection(
                    title: 'Industri',
                    children: [
                      BlocBuilder<BusinessSectorBloc, BusinessSectorState>(
                        builder: (context, state) {
                          if (state is BusinessSectorLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          if (state is BusinessSectorError) {
                            return Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.sm),
                              child: Text(
                                'Gagal memuat industri',
                                style: AppTypography.bodySmRegular
                                    .copyWith(color: AppColors.errorBase),
                              ),
                            );
                          }
                          final sectors = state is BusinessSectorLoaded
                              ? state.sectors
                              : <BusinessSectorModel>[];
                          return Column(
                            children: sectors.map((s) {
                              final isSelected =
                                  _selectedBusinessSectorIds.contains(s.id);
                              return _CheckboxItem(
                                isSelected: isSelected,
                                onTap: () => _toggleSector(s.id ?? 0),
                                label: Text(
                                  s.partnerCategoryName ?? '-',
                                  style: AppTypography.bodyMdRegular.copyWith(
                                    color: isSelected
                                        ? AppColors.primaryBase
                                        : AppColors.grey700,
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Footer sticky
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBase,
                            side: const BorderSide(
                                color: AppColors.primaryBase),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Text(
                            'Reset Filter',
                            style: AppTypography.headingXxs.copyWith(
                                color: AppColors.primaryBase),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child:
                            DsButton(text: 'Terapkan Filter', onPressed: _apply),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Section filter dengan judul + chevron collapse/expand.
class _FilterSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTypography.bodyMdSemiBold
                      .copyWith(color: AppColors.grey800),
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
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.grey100),
          const SizedBox(height: AppSpacing.xs),
          ...widget.children,
        ],
      ],
    );
  }
}

/// Satu baris item checkbox dalam filter.
class _CheckboxItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget label;

  const _CheckboxItem({
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBase
                    : AppColors.alwaysWhite,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBase
                      : AppColors.grey300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.alwaysWhite,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: label),
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
