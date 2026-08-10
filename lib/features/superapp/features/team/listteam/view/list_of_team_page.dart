import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import '../data/team_dummy.dart';
import '../model/team_member_model.dart';
import '../widget/team_member_card.dart';
import '../widget/team_search_bar.dart';

/// Halaman Daftar Tim: menampilkan anggota tim dalam dua tab
/// ("Internal" & "Talent Komtim") dengan pencarian nama/email dan filter.
///
/// Data masih dummy ([kDummyInternalTeam] / [kDummyTalentTeam]); ganti dengan
/// data dari bloc/repository saat endpoint tersedia.
class ListOfTeamPage extends StatefulWidget {
  const ListOfTeamPage({super.key});

  @override
  State<ListOfTeamPage> createState() => _ListOfTeamPageState();
}

class _ListOfTeamPageState extends State<ListOfTeamPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Daftar anggota untuk tab aktif setelah difilter oleh kata kunci pencarian.
  List<TeamMemberModel> get _visibleMembers {
    final source =
        _tabController.index == 0 ? kDummyInternalTeam : kDummyTalentTeam;
    if (_query.isEmpty) return source;

    final q = _query.toLowerCase();
    return source
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.email.toLowerCase().contains(q))
        .toList();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DsAppBar(title: 'Daftar Tim'),
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
                children: [
                  AppTabLayout(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Internal'),
                      Tab(text: 'Talent Komtim'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TeamSearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    // Filter disembunyikan dulu (onFilterTap dibiarkan null).
                  ),
                ],
              ),
            ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final members = _visibleMembers;

    if (members.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md3),
      itemBuilder: (context, index) => TeamMemberCard(member: members[index]),
    );
  }
}

/// Tampilan ketika hasil pencarian kosong.
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
              Icons.groups_2_outlined,
              size: AppSpacing.iconXxl,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Anggota tidak ditemukan',
              style: AppTypography.bodyLgSemiBold.copyWith(
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coba ubah kata kunci pencarianmu.',
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
