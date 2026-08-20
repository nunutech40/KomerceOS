import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/config/config.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/features/superapp/features/team/talentpool/bloc/business_sector_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/talentpool/bloc/talent_pool_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/talent_filter.dart';
import '../widget/talent_filter_sheet.dart';
import '../widget/talent_pool_header.dart';
import '../widget/talent_recommendation_card.dart';
import '../widget/talent_search_bar.dart';

/// Halaman Talent Pool: daftar talent dari API dengan filter multi-select
/// (rating, pengalaman, industri) dan pagination.
/// Tap kartu → buka web detail talent.
class TalentPoolPage extends StatelessWidget {
  const TalentPoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => locator<BusinessSectorBloc>()
            ..add(const FetchBusinessSectorEvent()),
        ),
        BlocProvider(
          create: (_) =>
              locator<TalentPoolBloc>()..add(const FetchTalentPoolEvent()),
        ),
      ],
      child: const _TalentPoolView(),
    );
  }
}

class _TalentPoolView extends StatefulWidget {
  const _TalentPoolView();

  @override
  State<_TalentPoolView> createState() => _TalentPoolViewState();
}

/// Daftar role hardcode untuk quick-filter.
/// Value dikirim sebagai `skill_name` ke API (URL-encoded otomatis oleh Dio).
/// Value kosong ('') = "Semua" → tidak mengirim skill_name, identik dengan load awal.
const List<({String label, String value})> _kHardcodedRoles = [
  (label: 'Semua', value: ''),
  (label: 'Customer Service', value: 'customer service'),
  (label: 'Admin Marketplace', value: 'admin marketplace'),
  (label: 'Advertiser', value: 'advertiser'),
  (label: 'Live Streamer', value: 'live streamer'),
];

class _TalentPoolViewState extends State<_TalentPoolView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isGridView = true;
  TalentFilter _filter = TalentFilter.empty;

  /// Role yang sedang dipilih.
  /// '' = "Semua" (aktif by default) → API dipanggil tanpa skill_name.
  String _selectedRole = '';

  String get _baseUrlTalentPool => Config.instance.baseUrlWebUrlTalentPool;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TalentPoolBloc>().add(const LoadMoreTalentPoolEvent());
    }
  }

  Future<void> _openFilter() async {
    final result =
        await TalentFilterSheet.show(context, initialFilter: _filter);
    if (result != null && mounted) {
      setState(() => _filter = result);
      context.read<TalentPoolBloc>().add(FetchTalentPoolEvent(
            ratings: result.selectedRatings.toList(),
            experiences: result.selectedExperiences.toList(),
            businessSectorIds: result.selectedBusinessSectorIds.toList(),
            skillName: result.skillName,
          ));
    }
  }

  /// Pilih role. Single-select.
  /// Memilih role yang sudah aktif (selain Semua) → kembali ke Semua.
  /// Memilih Semua → selalu kembali ke '' (fetch tanpa skill_name).
  void _onRoleSelected(String value) {
    // Tap role yang sama (bukan Semua) → kembali ke Semua.
    final newRole = (value == _selectedRole && value.isNotEmpty) ? '' : value;
    setState(() => _selectedRole = newRole);

    context.read<TalentPoolBloc>().add(FetchTalentPoolEvent(
          ratings: _filter.selectedRatings.toList(),
          experiences: _filter.selectedExperiences.toList(),
          businessSectorIds: _filter.selectedBusinessSectorIds.toList(),
          skillName: newRole, // '' = tanpa filter skill, sama seperti init
        ));
  }

  /// Pull-to-refresh: reset filter & pencarian, lalu fetch ulang dari awal.
  Future<void> _onRefresh() async {
    _searchController.clear();
    setState(() {
      _filter = TalentFilter.empty;
      _selectedRole = ''; // kembali ke Semua
    });

    final bloc = context.read<TalentPoolBloc>()
      ..add(const FetchTalentPoolEvent());

    // Tunggu sampai proses fetch selesai agar indikator refresh berhenti
    // tepat ketika data baru siap ditampilkan.
    await bloc.stream.firstWhere((state) => state is! TalentPoolLoading);
  }

  void _onSearchChanged(String value) {
    setState(() => _filter = _filter.copyWith(skillName: value));
    // Debounce bisa ditambahkan; untuk saat ini fetch langsung
    context.read<TalentPoolBloc>().add(FetchTalentPoolEvent(
          ratings: _filter.selectedRatings.toList(),
          experiences: _filter.selectedExperiences.toList(),
          businessSectorIds: _filter.selectedBusinessSectorIds.toList(),
          skillName: value,
        ));
  }

  Future<void> _openTalentDetail(TalentRecommendationModel talent) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final url = Uri.parse('$_baseUrlTalentPool/${talent.id}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka URL')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
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
                  const SizedBox(height: AppSpacing.sm),
                  // Role quick-filter chips (hardcoded, single-select)
                  _RoleFilterRow(
                    roles: _kHardcodedRoles,
                    selectedRole: _selectedRole,
                    onRoleSelected: _onRoleSelected,
                  ),
                  // Active filter chips (dari bottom sheet)
                  if (!_filter.isEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _ActiveFilterChips(
                      filter: _filter,
                      onClear: () {
                        setState(() => _filter = TalentFilter.empty);
                        context.read<TalentPoolBloc>().add(FetchTalentPoolEvent(
                              skillName: _selectedRole,
                            ));
                      },
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primaryBase,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<TalentPoolBloc, TalentPoolState>(
      listenWhen: (previous, current) =>
          current is TalentPoolWishlistSuccess ||
          current is TalentPoolWishlistFailed,
      listener: (context, state) {
        if (state is TalentPoolWishlistSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil ditambahkan ke Kandidat Saya'),
              backgroundColor: AppColors.successBase,
            ),
          );
        } else if (state is TalentPoolWishlistFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TalentPoolLoading) {
          return const _LoadingShimmer();
        }
        if (state is TalentPoolError) {
          return _RefreshableMessage(
            child: DsErrorState(
              message: state.message,
              onRetry: () => context
                  .read<TalentPoolBloc>()
                  .add(const FetchTalentPoolEvent()),
            ),
          );
        }
        if (state is TalentPoolEmpty) {
          return _RefreshableMessage(
            child: DsEmptyState(
              imagePath: 'assets/images/team/empty_state_feed.svg',
              title: !_filter.isEmpty
                  ? 'Talent tidak ditemukan'
                  : 'Belum ada talent tersedia',
              description: !_filter.isEmpty
                  ? 'Kami tidak menemukan talent yang cocok dengan pencarianmu. Coba kata kunci lain atau ubah filter.'
                  : 'Saat ini belum ada talent yang dapat direkomendasikan. Coba kembali nanti.',
            ),
          );
        }

        final talents = state is TalentPoolLoaded
            ? state.talents
            : (state is TalentPoolLoadingMore
                ? state.talents
                : <TalentRecommendationModel>[]);
        final isLoadingMore = state is TalentPoolLoadingMore;

        if (_isGridView) {
          return _TalentGrid(
            talents: talents,
            isLoadingMore: isLoadingMore,
            scrollController: _scrollController,
            onTap: _openTalentDetail,
            onWishlistTap: (talent) {
              context.read<TalentPoolBloc>().add(
                    ToggleWishlistTalentPoolEvent(talent.id),
                  );
            },
          );
        } else {
          return _TalentList(
            talents: talents,
            isLoadingMore: isLoadingMore,
            scrollController: _scrollController,
            onTap: _openTalentDetail,
            onWishlistTap: (talent) {
              context.read<TalentPoolBloc>().add(
                    ToggleWishlistTalentPoolEvent(talent.id),
                  );
            },
          );
        }
      },
    );
  }
}

// ────────────────────────────────────────────────
// Role quick-filter chips (hardcoded, single-select)
// ────────────────────────────────────────────────

class _RoleFilterRow extends StatelessWidget {
  final List<({String label, String value})> roles;
  final String? selectedRole;
  final void Function(String value) onRoleSelected;

  const _RoleFilterRow({
    required this.roles,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = selectedRole == role.value;
          return Center(
            child: _RoleChip(
              label: role.label,
              isSelected: isSelected,
              onTap: () => onRoleSelected(role.value),
            ),
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBase : AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.circular),
          border: Border.all(
            color: isSelected ? AppColors.primaryBase : AppColors.grey300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmSemiBold.copyWith(
            color: isSelected ? AppColors.alwaysWhite : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Active filter chips row
// ────────────────────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  final TalentFilter filter;
  final VoidCallback onClear;

  const _ActiveFilterChips({required this.filter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    int count = filter.selectedRatings.length +
        filter.selectedExperiences.length +
        filter.selectedBusinessSectorIds.length;

    return Row(
      children: [
        const Icon(Icons.tune_rounded,
            size: AppSpacing.iconSm, color: AppColors.primaryBase),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$count filter aktif',
          style: AppTypography.bodySmSemiBold
              .copyWith(color: AppColors.primaryBase),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onClear,
          child: Text(
            'Hapus semua',
            style:
                AppTypography.bodySmRegular.copyWith(color: AppColors.grey600),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────
// Grid content
// ────────────────────────────────────────────────

class _TalentGrid extends StatelessWidget {
  final List<TalentRecommendationModel> talents;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final void Function(TalentRecommendationModel) onTap;
  final void Function(TalentRecommendationModel) onWishlistTap;

  const _TalentGrid({
    required this.talents,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Manual 2-column masonry (tanpa package eksternal) ──
    // Item genap → kolom kiri, ganjil → kolom kanan.
    // Setiap kolom adalah Column biasa → card auto-fit kontennya.
    final leftIndices = <int>[];
    final rightIndices = <int>[];
    for (int i = 0; i < talents.length; i++) {
      if (i.isEven) {
        leftIndices.add(i);
      } else {
        rightIndices.add(i);
      }
    }

    Widget buildCard(int index) {
      final talent = talents[index];
      return TalentRecommendationGridCard(
        talent: talent,
        onTap: () => onTap(talent),
        onWishlistTap: () => onWishlistTap(talent),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        isLoadingMore ? AppSpacing.sm : AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom kiri — item genap (0, 2, 4, ...)
          Expanded(
            child: Column(
              children: [
                ...leftIndices.map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: buildCard(i),
                  ),
                ),
                if (isLoadingMore) const _GridShimmerCard(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Kolom kanan — item ganjil (1, 3, 5, ...)
          Expanded(
            child: Column(
              children: [
                ...rightIndices.map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: buildCard(i),
                  ),
                ),
                if (isLoadingMore) const _GridShimmerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// List content
// ────────────────────────────────────────────────

class _TalentList extends StatelessWidget {
  final List<TalentRecommendationModel> talents;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final void Function(TalentRecommendationModel) onTap;
  final void Function(TalentRecommendationModel) onWishlistTap;

  const _TalentList({
    required this.talents,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      itemCount: talents.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index >= talents.length) {
          return const _ListShimmerCard();
        }
        final talent = talents[index];
        return TalentRecommendationListCard(
          talent: talent,
          onTap: () => onTap(talent),
          onWishlistTap: () => onWishlistTap(talent),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────
// Shimmer loading
// ────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
        childAspectRatio: 0.52,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _GridShimmerCard(),
    );
  }
}

class _GridShimmerCard extends StatelessWidget {
  const _GridShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

class _ListShimmerCard extends StatelessWidget {
  const _ListShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Refreshable wrapper
// ────────────────────────────────────────────────

/// Membungkus pesan (empty/error) agar tetap bisa ditarik untuk refresh
/// walau kontennya tidak memenuhi satu layar.
class _RefreshableMessage extends StatelessWidget {
  final Widget child;

  const _RefreshableMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
