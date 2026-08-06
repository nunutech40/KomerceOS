import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_chart.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_menu_icon.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_transaction_tile.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_skeleton.dart';

/// Section menu + chart PageView + Transaksi Kartu.
///
/// Menerima [captureKey] dan [onSaveChart] dari parent untuk fungsi
/// simpan chart ke galeri (butuh akses ke RepaintBoundary).
class MenuContentSection extends StatefulWidget {
  const MenuContentSection({
    super.key,
    required this.captureKey,
    required this.isSavingChart,
    required this.onSaveChart,
  });

  final GlobalKey captureKey;
  final bool isSavingChart;
  final VoidCallback onSaveChart;

  @override
  State<MenuContentSection> createState() => _MenuContentSectionState();
}

class _MenuContentSectionState extends State<MenuContentSection> {
  final PageController _pageController = PageController();
  int _currentSwipePage = 0;
  final GlobalKey<DsChartState> _dsChartKey = GlobalKey<DsChartState>();

  // ---------------------------------------------------------------------------
  // State filter grafik komship: bulan/tahun terpilih + metode pembayaran.
  // Default = bulan & tahun sekarang (tanggal hari ini).
  // ---------------------------------------------------------------------------
  DateTime _selectedMonth = DateTime.now();
  String? _selectedPaymentMethod;

  /// Format tanggal ke `yyyy-MM-dd` untuk API.
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Awal bulan terpilih.
  String get _startDate =>
      _fmt(DateTime(_selectedMonth.year, _selectedMonth.month, 1));

  /// Akhir rentang: hari ini bila bulan terpilih = bulan berjalan,
  /// selain itu akhir bulan terpilih.
  String get _endDate {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final end = isCurrentMonth
        ? DateTime(now.year, now.month, now.day)
        : DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    return _fmt(end);
  }

  /// Label tombol filter, mis. "Mar 2023" (nama bulan disingkat 3 huruf).
  String get _monthYearLabel {
    final month = DsDateFilterSheet.defaultMonthNames[_selectedMonth.month - 1];
    final shortMonth = month.substring(0, 3);
    return '$shortMonth ${_selectedMonth.year}';
  }

  void _fetchRevenue() {
    context.read<RevenuePerformanceBloc>().add(
          FetchRevenuePerformanceEvent(
            startDate: _startDate,
            endDate: _endDate,
            paymentMethod: _selectedPaymentMethod,
          ),
        );
  }

  Future<void> _openDateFilter() async {
    final now = DateTime.now();
    final result = await DsDateFilterSheet.show(
      context,
      initial: DsMonthYear(
        month: _selectedMonth.month,
        year: _selectedMonth.year,
      ),
      minYear: now.year - 5,
      maxYear: now.year,
    );

    if (result != null && mounted) {
      setState(() => _selectedMonth = DateTime(result.year, result.month));
      _fetchRevenue();
    }
  }

  // Definisi data transaksi terakhir (placeholder)
  static const List<DsTransactionItem> _transactions = [
    DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025'),
    DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025'),
    DsTransactionItem(
        title: 'Facebook ads',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025'),
    DsTransactionItem(
        title: 'Shopee payment product des...',
        cardName: 'Tiktok Card',
        amount: 'Rp 99.999.999',
        date: '20 april 2025'),
    DsTransactionItem(
        title: 'Tiktok ads payment',
        cardName: 'Tiktok Card',
        amount: 'Rp 50.000',
        date: '20 april 2025'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildKomshipChartPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RepaintBoundary(
        key: widget.captureKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            border: Border.all(color: const Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DsAppImage(
                    source: 'assets/images/superapp/home/ic_logo_komship.svg',
                    height: 24,
                    width: 112,
                  ),
                  if (!widget.isSavingChart)
                    GestureDetector(
                      onTap: widget.onSaveChart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.alwaysWhite,
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/superapp/home/ic_share.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Share',
                              style: AppTypography.bodyMdMedium
                                  .copyWith(color: const Color(0xFF0A0A0A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Performa Omset & Orderan',
                style: AppTypography.bodyLgBold
                    .copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau semua pendapatan kamu disini',
                style: AppTypography.bodyMdRegular
                    .copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.alwaysWhite,
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DefaultTabController(
                  length: 3,
                  child: BlocBuilder<RevenuePerformanceBloc,
                      RevenuePerformanceState>(
                    builder: (context, state) {
                      final totalOmset = state is RevenuePerformanceLoaded
                          ? state.totalOmset
                          : 0;
                      final totalOrder = state is RevenuePerformanceLoaded
                          ? state.totalOrder
                          : 0;
                      final omzetSpots = state is RevenuePerformanceLoaded
                          ? state.omzetSpots
                          : const <FlSpot>[];
                      final orderSpots = state is RevenuePerformanceLoaded
                          ? state.orderSpots
                          : const <FlSpot>[];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris label + tombol filter tanggal
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Total Omset',
                                  style: AppTypography.bodyMdRegular.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Total Orderan',
                                  style: AppTypography.bodyMdRegular.copyWith(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _DateFilterButton(
                                label: _monthYearLabel,
                                onTap: _openDateFilter,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Baris nilai (sejajar tepat di bawah label di atasnya)
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  CurrencyFormat.convertToIdrNum(totalOmset, 0),
                                  style: AppTypography.bodyLgMedium.copyWith(
                                    color: AppColors.black1A1A,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$totalOrder',
                                  style: AppTypography.bodyLgMedium.copyWith(
                                    color: AppColors.black1A1A,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Placeholder selebar tombol filter agar kolom nilai
                              // tetap sejajar dengan kolom label di baris atas.
                              Visibility(
                                visible: false,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: _DateFilterButton(
                                  label: _monthYearLabel,
                                  onTap: _openDateFilter,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppTabLayout(
                            onTap: (index) {
                              String? method;
                              if (index == 1) method = 'cod';
                              if (index == 2) method = 'bank transfer';
                              _selectedPaymentMethod = method;
                              _fetchRevenue();
                            },
                            tabs: const [
                              Tab(text: 'Semua'),
                              Tab(text: 'COD'),
                              Tab(text: 'Non COD'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (state is RevenuePerformanceInitial ||
                              state is RevenuePerformanceLoading)
                            const HomeChartSkeleton()
                          else if (state is RevenuePerformanceError)
                            SizedBox(
                              height: 200,
                              child: Center(child: Text(state.message)),
                            )
                          else
                            DsChart(
                              key: _dsChartKey,
                              omzet: omzetSpots,
                              orders: orderSpots,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipe2Placeholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            'Swipe 2 Data Placeholder',
            style: AppTypography.bodyLgMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransaksiKartu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Transaksi Terakhir Kartu',
                style: AppTypography.headingSm.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: List.generate(_transactions.length, (index) {
                  final item = _transactions[index];
                  final isLast = index == _transactions.length - 1;
                  return Column(
                    children: [
                      DsTransactionTile(item: item),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E5E5),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuperappProfileBloc, SuperappProfileState>(
      buildWhen: (prev, curr) =>
          prev.displayProfile?.isKomship != curr.displayProfile?.isKomship ||
          prev.displayProfile?.isKomcards != curr.displayProfile?.isKomcards ||
          prev.displayProfile?.productMailVerifications !=
              curr.displayProfile?.productMailVerifications ||
          prev.isBackgroundRefresh != curr.isBackgroundRefresh ||
          prev.status != curr.status,
      builder: (context, profileState) {
        final hasKomship = profileState.isKomshipVerified;
        final hasKomcards = profileState.isKomcardsVerified;

        // Skeleton saat loading / background refresh
        final isLoading =
            profileState.status == SuperappProfileStatus.loading ||
                profileState.status == SuperappProfileStatus.loadingWithCache ||
                profileState.status == SuperappProfileStatus.initial ||
                profileState.isBackgroundRefresh;

        if (isLoading) {
          return Column(
            children: [
              const HomeMenuSkeleton(),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const HomeChartSkeleton(),
                ),
              ),
            ],
          );
        }

        // Menu items
        final menuItems = <Widget>[
          DsMenuIcon(
            icon: Image.asset('assets/images/superapp/home/ic_team.png'),
            title: 'Team',
            onTap: () {
              AppRouter.router.pushNamed(PAGES.team.screenName);
            },
          ),
        ];

        if (hasKomship) {
          menuItems.addAll([
            DsMenuIcon(
              icon: Image.asset('assets/images/superapp/home/ic_order.png'),
              title: 'Order',
              onTap: () {},
            ),
            DsMenuIcon(
              icon: Image.asset('assets/images/superapp/home/ic_problem.png'),
              title: 'Kendala',
              onTap: () {},
            ),
          ]);
        }

        // Swipe pages
        final allSwipePages = [
          _buildKomshipChartPage(),
          _buildSwipe2Placeholder()
        ];
        final activeSwipePages = <Widget>[];
        if (hasKomship) activeSwipePages.add(allSwipePages[0]);
        if (hasKomcards) activeSwipePages.add(allSwipePages[1]);

        return Column(
          children: [
            // Grid menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: menuItems,
              ),
            ),

            // PageView chart carousel
            if (activeSwipePages.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                height: 680,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentSwipePage = index),
                  children: activeSwipePages,
                ),
              ),
              const SizedBox(height: 12),
              // Dot indicator
              if (activeSwipePages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(activeSwipePages.length, (index) {
                    final isActive = _currentSwipePage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 12,
                      width: isActive ? 32 : 12,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryBase
                            : AppColors.grey350,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
            ],

            // Transaksi Terakhir Kartu
            if (hasKomcards) ...[
              const SizedBox(height: 16),
              _buildTransaksiKartu(),
            ],
          ],
        );
      },
    );
  }
}

/// Tombol pemicu filter tanggal (bulan/tahun) di samping card Total Omset.
class _DateFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateFilterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmMedium
              .copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
