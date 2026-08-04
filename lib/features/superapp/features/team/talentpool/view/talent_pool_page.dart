import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import '../data/talent_dummy.dart';
import '../model/talent_filter.dart';
import '../model/talent_model.dart';
import '../widget/talent_filter_sheet.dart';
import '../widget/talent_grid_card.dart';
import '../widget/talent_list_card.dart';
import '../widget/talent_pool_header.dart';
import '../widget/talent_search_bar.dart';

/// Halaman Talent Pool: menampilkan rekomendasi talent dalam mode
/// grid atau list, dengan pencarian dan filter.
class TalentPoolPage extends StatefulWidget {
  const TalentPoolPage({super.key});

  @override
  State<TalentPoolPage> createState() => _TalentPoolPageState();
}

class _TalentPoolPageState extends State<TalentPoolPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isGridView = true;
  String _searchQuery = '';
  TalentFilter _filter = const TalentFilter();
  final List<TalentModel> _talents = List.of(kDummyTalents);

  /// Talent yang lolos pencarian + filter (role, industri) lalu diurutkan
  /// sesuai opsi "Urutkan" yang dipilih.
  List<TalentModel> get _filteredTalents {
    final query = _searchQuery.toLowerCase();

    final result = _talents.where((t) {
      final matchSearch = query.isEmpty ||
          t.name.toLowerCase().contains(query) ||
          t.role.toLowerCase().contains(query);
      final matchRole = !_filter.hasRole || t.role == _filter.role;
      final matchIndustry =
          !_filter.hasIndustry || t.industries.contains(_filter.industry);
      return matchSearch && matchRole && matchIndustry;
    }).toList();

    _sortTalents(result);
    return result;
  }

  /// Mengurutkan [talents] in-place sesuai [_filter.sort].
  void _sortTalents(List<TalentModel> talents) {
    if (!_filter.hasSort) return;
    switch (_filter.sort) {
      case TalentFilterOptions.sortTopRated:
        talents.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case TalentFilterOptions.sortMostMarked:
        talents.sort((a, b) => b.markedByPartner.compareTo(a.markedByPartner));
        break;
      case TalentFilterOptions.sortLongestExperience:
        talents.sort(
            (a, b) => b.experienceInMonths.compareTo(a.experienceInMonths));
        break;
      case TalentFilterOptions.sortTopConversion:
        talents.sort((a, b) => b.conversionRate.compareTo(a.conversionRate));
        break;
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  Future<void> _openFilter() async {
    final result = await TalentFilterSheet.show(context, initialFilter: _filter);
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  void _toggleFavorite(TalentModel talent) {
    final index = _talents.indexOf(talent);
    if (index == -1) return;
    setState(() {
      _talents[index] = talent.copyWith(isFavorite: !talent.isFavorite);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DsAppBar(title: 'Talent Pool'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TalentPoolHeader(),
                  const SizedBox(height: AppSpacing.md),
                  TalentSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onFilterTap: _openFilter,
                    isGridView: _isGridView,
                    onViewChanged: (value) =>
                        setState(() => _isGridView = value),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final talents = _filteredTalents;
    if (talents.isEmpty) {
      return const _EmptyState();
    }
    return _isGridView
        ? _TalentGrid(talents: talents, onFavoriteTap: _toggleFavorite)
        : _TalentList(talents: talents, onFavoriteTap: _toggleFavorite);
  }
}

class _TalentGrid extends StatelessWidget {
  final List<TalentModel> talents;
  final ValueChanged<TalentModel> onFavoriteTap;

  const _TalentGrid({required this.talents, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.62,
      ),
      itemCount: talents.length,
      itemBuilder: (context, index) {
        final talent = talents[index];
        return TalentGridCard(
          talent: talent,
          onFavoriteTap: () => onFavoriteTap(talent),
        );
      },
    );
  }
}

class _TalentList extends StatelessWidget {
  final List<TalentModel> talents;
  final ValueChanged<TalentModel> onFavoriteTap;

  const _TalentList({required this.talents, required this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      itemCount: talents.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final talent = talents[index];
        return TalentListCard(
          talent: talent,
          onFavoriteTap: () => onFavoriteTap(talent),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_search_rounded,
              size: AppSpacing.iconXxl,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Talent tidak ditemukan',
              style: AppTypography.bodyLgSemiBold.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coba ubah kata kunci atau filter pencarianmu.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmRegular.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
