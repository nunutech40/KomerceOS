import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/pages/shimmer.dart';

import '../../../../../../core/domain/entities/team_member_model.dart';
import '../../../../../../di/injection.dart';
import '../bloc/list_of_team_bloc.dart';
import '../bloc/list_of_team_event.dart';
import '../bloc/list_of_team_state.dart';
import '../widget/dash_line_team.dart';
import '../widget/team_member_card.dart';
import '../widget/team_search_bar.dart';

/// Halaman Daftar Tim: menampilkan anggota tim dalam dua tab
/// ("Internal" & "Talent Komtim") dengan pencarian nama/email dan filter.
class ListOfTeamPage extends StatelessWidget {
  const ListOfTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<ListOfTeamBloc>()
        ..add(const FetchInternalTeamsEvent())
        ..add(const FetchKomtimTeamsEvent()),
      child: const ListOfTeamView(),
    );
  }
}

class ListOfTeamView extends StatefulWidget {
  const ListOfTeamView({super.key});

  @override
  State<ListOfTeamView> createState() => _ListOfTeamViewState();
}

class _ListOfTeamViewState extends State<ListOfTeamView>
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
  List<TeamMemberModel> _getVisibleMembers(ListOfTeamState state) {
    final source =
        _tabController.index == 0 ? state.internalTeams : state.komtimTeams;
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
      backgroundColor: AppColors.alwaysWhite,
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
                    variant: AppTabLayoutVariant.elevated,
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
            Expanded(
              child: BlocBuilder<ListOfTeamBloc, ListOfTeamState>(
                builder: (context, state) {
                  if (state.status == ListOfTeamStatus.loading &&
                      state.internalTeams.isEmpty &&
                      state.komtimTeams.isEmpty) {
                    return const _TeamListShimmer();
                  }

                  if (state.status == ListOfTeamStatus.failure &&
                      state.internalTeams.isEmpty &&
                      state.komtimTeams.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primaryBase,
                      onRefresh: () async {
                        context
                            .read<ListOfTeamBloc>()
                            .add(const FetchInternalTeamsEvent());
                        context
                            .read<ListOfTeamBloc>()
                            .add(const FetchKomtimTeamsEvent());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          alignment: Alignment.center,
                          child: Text(state.errorMessage),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryBase,
                    onRefresh: () async {
                      context
                          .read<ListOfTeamBloc>()
                          .add(const FetchInternalTeamsEvent());
                      context
                          .read<ListOfTeamBloc>()
                          .add(const FetchKomtimTeamsEvent());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: _buildList(state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ListOfTeamState state) {
    final members = _getVisibleMembers(state);

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
///
/// Dibungkus `LayoutBuilder` + `ConstrainedBox(minHeight)` + scroll agar
/// kontennya SELALU tampil di tengah area yang tersedia (bukan cuma di
/// tengah lebar layar), dan tetap aman dari overflow bila konten lebih
/// tinggi dari ruang yang tersisa (mis. layar kecil / keyboard terbuka).
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DsAppImage(
                      width: 200,
                      height: 200,
                      source: 'assets/images/team/empty_state_feed.svg',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tim Tidak Ditemukan',
                      style: AppTypography.bodyLgSemiBold.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kami tidak menemukan tim yang cocok dengan\npencarianmu. Coba kata kunci lain atau ubah filter.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TeamListShimmer extends StatelessWidget {
  const _TeamListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md3),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md3),
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerContainer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerContainer(
                          child: Container(
                            height: 16,
                            width: 120,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        ShimmerContainer(
                          child: Container(
                            height: 20,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    ShimmerContainer(
                      child: Container(
                        height: 12,
                        width: 160,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md3),
                    const DashedLine(dashWidth: 6, dashGap: 4),
                    const SizedBox(height: AppSpacing.md3),
                    ShimmerContainer(
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

