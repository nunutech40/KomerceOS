import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/time_convert.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';
import 'package:komtim_partner/core/data/models/profile_response.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_weekly_model.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_event.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_state.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_month.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_shimmer_report_performance.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_today.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_week.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/custom_showmodal_report_performance_today.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/custom_showmodal_report_performance_week.dart';

class ReportPerformancePages extends StatefulWidget {
  const ReportPerformancePages({super.key});

  @override
  State<ReportPerformancePages> createState() => _ReportPerformancePagesState();
}

class _ReportPerformancePagesState extends State<ReportPerformancePages>
    with TickerProviderStateMixin, ErrorHandlingMixin {
  TabController? _tabController;
  final _textEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int valueTab = 0;
  late ReportPerformanceBloc _bloc;

  // Data management untuk today tab
  List<ReportPerformanceModel> listDataToday = [];
  List<ReportPerformanceModel> filterListDataToday = [];
  List<ReportPerformanceWeeklyModel> listDataWeek = [];
  List<ReportPerformanceWeeklyModel> filteredDataWeek = [];
  List<ReportPerformanceMonthlyModel> listDataMonth = [];
  List<ReportPerformanceMonthlyModel> filteredDataMonth = [];
  List<ReportPerformanceProductModel> listDataProduct = [];
  Set<int> expandedItems = <int>{}; // Track expanded items by ID

  String firstDate = '';
  String lastDate = '';
  int todayFilterValue = 0;
  bool hasDateFilter = false; // Replace statusFilter and valueFilter
  bool hasWeeklyProductFilter = false;

  // Pagination variables
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;
  final int maxAttempts = 3;
  int attemptCount = 0;

  String? _selectedMonth;
  String? _selectedWeek;
  bool _isProductListLoaded = false;
  String? selectedProductId;

  Timer? _debounce;

  // Method untuk handle search dengan debounce
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearchSubmitted(value);
    });
  }

  // Method untuk handle search submit - IMPROVED
  void _onSearchSubmitted(String value) {
    setState(() {
      _offset = 0; // Reset ke halaman pertama
      _hasNextPage = true; // Aktifkan pemuatan halaman berikutnya
      attemptCount = 0; // Reset jumlah percobaan
      listDataToday.clear(); // Hapus data lama
      listDataToday.clear(); // Hapus data yang difilter
    });

    // Kirim permintaan API baru dengan parameter pencarian dan filter tanggal
    _bloc.add(GetReportPerformanceEvent(
      search: _textEditingController.text, // Gunakan teks pencarian terbaru
      limit: _limit.toString(), // Batas data per halaman
      offset: _offset.toString(), // Offset untuk pagination
      startDate: hasDateFilter
          ? firstDate
          : firstDate, // Filter tanggal awal jika aktif
      endDate: hasDateFilter
          ? lastDate
          : lastDate, // Filter tanggal akhir jika aktif
    ));
  }

  final List<String> _listMonths = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<String> _listWeek = [
    'Week 1',
    'Week 2',
    'Week 3',
    'Week 4',
    'Week 5',
  ];

  @override
  final pref = di.locator<SharedPref>();
  ProfileResponse? profileResponse;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);

    _initializeBloc();
    _setDefaultSelections();
    // Pastikan product list di-fetch di awal
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      profileResponse = await pref.getProfileResponse();
      // Fetch product list once during initialization
      _fetchProductList();
    });
    _loadData();

    _scrollController.addListener(_scrollListener);
    _tabController?.addListener(_handleTabSelection);
  }

// Add method to fetch product list
  void _fetchProductList() {
    if (!_isProductListLoaded && profileResponse != null) {
      String partnerId = profileResponse?.partnerId.toString() ?? '';
      _bloc.add(GetReportPerformanceProductEvent(
        keyword: '',
        parentId: partnerId,
      ));
      _isProductListLoaded = true;
    }
  }

  _initializeBloc() {
    _bloc = context.read<ReportPerformanceBloc>();
  }

  // IMPROVED - Load data method
  _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _offset = 0;
      listDataToday.clear();
      filterListDataToday.clear();
      attemptCount = 0;
      _hasNextPage = true;
    });

    if (firstDate.isEmpty || lastDate.isEmpty) {
      await _getDate();
    }

    _bloc.add(GetReportPerformanceEvent(
      search: _textEditingController.text,
      limit: _limit.toString(),
      offset: _offset.toString(),
      startDate: firstDate,
      endDate: lastDate,
    ));
  }

  // IMPROVED - Load more data method
  _loadMoreData() async {
    if (_isLoadingMore ||
        !_hasNextPage ||
        attemptCount >= maxAttempts ||
        hasDateFilter ||
        _textEditingController.text.isNotEmpty) {
      return; // Tidak load more jika ada filter aktif
    }

    setState(() {
      _isLoadingMore = true;
    });
    // debugPrint("scroll  ($_offset + $_limit).toString(),");
    _bloc.add(GetReportPerformanceEvent(
      search: _textEditingController.text,
      limit: _limit.toString(),
      offset: (_offset + _limit).toString(),
      startDate: firstDate,
      endDate: lastDate,
    ));
  }

  void _scrollListener() {
    if (valueTab == 0) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    } else if (valueTab == 1) {
      _weeklyScrollListener();
    } else if (valueTab == 2) {
      _monthlyScrollListener();
    }
  }

  void _handleTabSelection() {
    if (_tabController?.indexIsChanging ?? false) {
      setState(() {
        _isTabChanging = true;
      });
      int newTab = _tabController!.index;

      if (newTab == 0) {
        setState(() {
          _offset = 0;
          _hasNextPage = true;
          attemptCount = 0;
          listDataToday.clear();
          filterListDataToday.clear();
        });
        _loadData();
      } else if (newTab == 1) {
        setState(() {
          // Reset weekly data and pagination
          _offset = 0;
          _hasNextPage = true;
          attemptCount = 0;
          listDataWeek.clear();
          filteredDataWeek.clear();
        });
        if (_selectedWeek != null) {
          _loadWeeklyData();
        }
      } else if (newTab == 2) {
        setState(() {
          // Reset monthly data and pagination
          _offset = 0;
          _hasNextPage = true;
          attemptCount = 0;
          listDataMonth.clear();
          filteredDataMonth.clear();
        });
        if (_selectedMonth != null) {
          _loadMonthlyData();
        }
      }
      setState(() {
        valueTab = newTab;
        _isTabChanging = false;
      });
    }
  }

  // Infinite scroll for weekly tab
  void _weeklyScrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreWeeklyData();
    }
  }

  void _loadMoreWeeklyData() async {
    if (_isLoadingMore || !_hasNextPage || attemptCount >= maxAttempts) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    final weekNumber = _selectedWeek != null
        ? int.parse(_selectedWeek!.replaceAll('Week ', ''))
        : 1;
    _bloc.add(GetReportPerformanceWeekEvent(
      limit: _limit,
      offset: (_offset + _limit),
      week: weekNumber,
      month: '',
      keyword: '',
      productId: selectedProductId ?? '',
    ));
  }

  // Infinite scroll for monthly tab
  void _monthlyScrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMonthlyData();
    }
  }

  void _loadMoreMonthlyData() async {
    if (_isLoadingMore || !_hasNextPage || attemptCount >= maxAttempts) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    final monthNumber =
        _selectedMonth != null ? _listMonths.indexOf(_selectedMonth!) + 1 : 1;
    _bloc.add(GetReportPerformanceMonthEvent(
      limit: _limit,
      offset: (_offset + _limit),
      month: monthNumber,
    ));
  }

  _getDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    setState(() {
      firstDate = formattedDate;
      lastDate = formattedDate;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _offset = 0;
      _hasNextPage = true;
      listDataToday.clear();
      filterListDataToday.clear();
      attemptCount = 0;
      todayFilterValue = 0;
      hasDateFilter = false;
      _textEditingController.clear();
    });
    await _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController?.dispose();
    _textEditingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Method untuk set default week dan month - IMPROVED
  void _setDefaultSelections() {
    DateTime now = DateTime.now();

    // Set default month ke bulan sekarang
    _selectedMonth = _listMonths[now.month - 1];

    // Hitung minggu keberapa dalam bulan ini dengan lebih akurat
    int currentWeek = _getCurrentWeekOfMonth(now);
    _selectedWeek = 'Week $currentWeek';

    // print(
    //     'Default selections set - Month: $_selectedMonth, Week: $_selectedWeek');
  }

// Helper method untuk menghitung minggu ke berapa dalam bulan - IMPROVED
  int _getCurrentWeekOfMonth(DateTime date) {
    // Dapatkan tanggal 1 di bulan yang sama
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);

    // Dapatkan hari dalam minggu untuk tanggal 1 (1 = Monday, 7 = Sunday)
    int firstDayWeekday = firstDayOfMonth.weekday;

    // Hitung offset hari untuk memulai minggu dari Senin
    int offset = firstDayWeekday - 1;

    // Hitung minggu berdasarkan posisi tanggal saat ini
    int dayOfMonth = date.day;
    int weekNumber = ((dayOfMonth + offset - 1) / 7).floor() + 1;

    // Pastikan tidak melebihi week 5 dan minimal week 1
    return weekNumber.clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const DsAppBar(title: 'Report Performa'),
      backgroundColor: AppColors.alwaysWhite,
      body: Column(
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
                  onTap: showHiddenButton,
                  tabs: const [
                    Tab(text: 'Harian'),
                    Tab(text: 'Mingguan'),
                    Tab(text: 'Bulanan'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTabContent(),
              ],
            ),
          ),
          Expanded(child: _buildListView()),
        ],
      ),
    );
  }

  // IMPROVED - Status filter string method
  String statusFilterString() {
    if (hasDateFilter) {
      return '${firstDate.replaceAll('-', '/')} - ${lastDate.replaceAll('-', '/')}';
    }
    return 'Harian';
  }

  /// Expand division abbreviation to full name
  String _expandDivisionName(String division) {
    switch (division.toUpperCase()) {
      case 'CS':
        return 'Customer Service';
      case 'ADV':
        return 'Advertiser';
      case 'SPV':
        return 'Supervisor';
      default:
        return division;
    }
  }

  Widget _buildTabContent() {
    switch (valueTab) {
      case 0:
        return _buildDailyFilter();
      case 1:
        return _buildWeeklyFilter();
      case 2:
        return _buildMonthlyFilter();
      default:
        return const SizedBox();
    }
  }

  Widget _buildListView() {
    switch (valueTab) {
      case 0:
        return _buildListviewToday();
      case 1:
        return _buildListviewWeek();
      case 2:
        return _buildListviewMonth();
      default:
        return const SizedBox();
    }
  }

  // IMPROVED - ListView today dengan pengelolaan data yang lebih baik
  Widget _buildListviewToday() {
    return BlocConsumer<ReportPerformanceBloc, ReportPerformanceState>(
      listener: (context, state) {
        if (state.status == RequestStatus.empty) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _hasNextPage = false;
          });
        } else if (state.status == RequestStatus.failure) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state.status == RequestStatus.success) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;

            List<ReportPerformanceModel> newData =
                state.reportPerformance ?? [];

            if (_offset == 0) {
              // Reset data saat load pertama kali
              listDataToday = newData;
              filterListDataToday =
                  List.from(newData); // Langsung gunakan data dari server
              attemptCount = 0;
            } else {
              // Tambah data untuk infinite scroll
              if (newData.isEmpty) {
                attemptCount++;
                if (attemptCount >= maxAttempts) {
                  _hasNextPage = false;
                }
              } else {
                attemptCount = 0;
                listDataToday.addAll(newData);
                filterListDataToday = List.from(listDataToday);
                _offset += _limit;
              }
            }

            // Cek apakah masih ada data selanjutnya
            if (newData.length < _limit) {
              _hasNextPage = false;
            }
          });
        }
      },
      builder: (context, state) {
        if (valueTab != 0) {
          return const SizedBox(); // Return empty jika bukan tab harian
        }

        List<ReportPerformanceModel> displayData = _getDisplayData();

        // PERBAIKAN: Kondisi shimmer yang lebih spesifik
        // Hanya tampilkan shimmer jika benar-benar loading data pertama kali
        bool shouldShowShimmer = _isLoading &&
            displayData.isEmpty &&
            !_isTabChanging &&
            valueTab == 0;

        if (shouldShowShimmer) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: 10,
            itemBuilder: (context, index) {
              return const CardShimmerReportPerformance();
            },
          );
        }

        // Show empty state
        if (displayData.isEmpty && !_isLoading) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DsEmptyState(
                    imagePath: 'assets/images/team/empty_state_feed.svg',
                    title: 'Report Performa Kosong',
                    description: _getEmptyStateMessage(),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount:
                  displayData.length + (_shouldShowLoadingIndicator() ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator di bottom
                if (index == displayData.length) {
                  if (attemptCount >= maxAttempts) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: _isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final item = displayData[index];
                final itemId = item.id ?? index;
                final isExpanded = expandedItems.contains(itemId);

                return CardToday(
                  name: item.talentName ?? "",
                  role: _expandDivisionName(item.division ?? ""),
                  date: formatToIndonesianDateNextDay(item.reportDate ?? ""),
                  nameProduct: item.productName ?? "",
                  leads: item.leads.toString(),
                  transaksi: item.transaction.toString(),
                  cr: convertCR(item.cr ?? 0),
                  cbt: item.cb.toString(),
                  keterangan: item.description ?? "",
                  ontap: () {},
                  status: isExpanded,
                  ontap2: () {
                    setState(() {
                      if (isExpanded) {
                        expandedItems.remove(itemId);
                      } else {
                        expandedItems.add(itemId);
                      }
                    });
                  },
                );
              },
            ));
      },
    );
  }

  // Helper method untuk menentukan data yang akan ditampilkan
  List<ReportPerformanceModel> _getDisplayData() {
    // Jika ada filter tanggal atau pencarian, filter data dari listDataToday
    if (hasDateFilter || _textEditingController.text.isNotEmpty) {
      return listDataToday.where((item) {
        final matchesSearch = _textEditingController.text.isEmpty ||
            (item.talentName
                    ?.toLowerCase()
                    .contains(_textEditingController.text.toLowerCase()) ??
                false);
        // Jika ada filter tanggal, tambahkan logika filter tanggal di sini jika diperlukan
        return matchesSearch;
      }).toList();
    }
    return listDataToday;
  }

  // Helper method untuk menentukan apakah perlu menampilkan loading indicator
  bool _shouldShowLoadingIndicator() {
    return _hasNextPage &&
        !hasDateFilter &&
        _textEditingController.text.isEmpty;
  }

  // Helper method untuk pesan empty state
  String _getEmptyStateMessage() {
    if (_textEditingController.text.isNotEmpty) {
      return 'Tidak ada data dengan pencarian "${_textEditingController.text}"';
    } else if (hasDateFilter) {
      return 'Tidak ada data pada periode yang dipilih';
    } else {
      return 'Belum ada data performa talent untuk ditampilkan';
    }
  }

  // Weekly helper methods
  List<ReportPerformanceWeeklyModel> _getWeeklyDisplayData() {
    return hasWeeklyProductFilter ? filteredDataWeek : listDataWeek;
  }

  bool _shouldShowWeeklyLoadingIndicator() {
    return _hasNextPage && !hasWeeklyProductFilter;
  }

  String _getWeeklyEmptyStateMessage() {
    if (hasWeeklyProductFilter) {
      return 'Tidak ada data pada filter yang dipilih';
    }
    return 'Belum ada data performa talent untuk ditampilkan';
  }

  Future<void> _refreshWeeklyData() async {
    setState(() {
      _offset = 0;
      _hasNextPage = true;
      listDataWeek.clear();
      filteredDataWeek.clear();
      attemptCount = 0;
    });

    if (_selectedWeek != null) {
      _loadWeeklyData();
    }
  }

  void _loadWeeklyData() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _offset = 0;
      listDataWeek = [];
      filteredDataWeek = [];
      attemptCount = 0;
      _hasNextPage = true;
    });

    // Extract week number from selected week
    final weekNumber = _selectedWeek != null
        ? int.parse(_selectedWeek!.replaceAll('Week ', ''))
        : 1;

    _bloc.add(GetReportPerformanceWeekEvent(
      limit: _limit,
      offset: _offset,
      week: weekNumber,
      keyword: '', // Add keyword if needed
      month: '', // Add month if needed
      productId: selectedProductId ?? '', // Pastikan productId dikirim
    ));
  }

  Widget _buildListviewWeek() {
    return BlocConsumer<ReportPerformanceBloc, ReportPerformanceState>(
        listener: (context, state) {
      if (state.status == RequestStatus.empty) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _hasNextPage = false;
        });
      } else if (state.status == RequestStatus.failure) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.message}')),
        );
      } else if (state.status == RequestStatus.success) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;

          var newData = state.reportPerformanceWeekly ?? [];

          if (_offset == 0) {
            // Reset data for first load
            listDataWeek = newData;
            filteredDataWeek = List.from(newData);
            attemptCount = 0;
          } else {
            // Add data for infinite scroll
            if (newData.isEmpty) {
              attemptCount++;
              if (attemptCount >= maxAttempts) {
                _hasNextPage = false;
              }
            } else {
              attemptCount = 0;
              listDataWeek.addAll(newData);
              filteredDataWeek = List.from(listDataWeek);
              _offset += _limit;
            }
          }

          // Check if there's more data
          if (newData.length < _limit) {
            _hasNextPage = false;
          }
        });
      }
    }, builder: (context, state) {
      if (valueTab != 1) {
        return const SizedBox(); // Return empty if not weekly tab
      }

      List<ReportPerformanceWeeklyModel> displayData = _getWeeklyDisplayData();

      // Show shimmer loading
      bool shouldShowShimmer =
          _isLoading && displayData.isEmpty && !_isTabChanging && valueTab == 1;

      if (shouldShowShimmer) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: 10,
          itemBuilder: (context, index) {
            return const CardShimmerReportPerformance();
          },
        );
      }

      // Show empty state
      if (displayData.isEmpty && !_isLoading) {
        return RefreshIndicator(
          onRefresh: _refreshWeeklyData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: DsEmptyState(
                  imagePath: 'assets/images/team/empty_state_feed.svg',
                  title: 'Report Performa Kosong',
                  description: _getWeeklyEmptyStateMessage(),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
          onRefresh: _refreshWeeklyData,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: displayData.length +
                (_shouldShowWeeklyLoadingIndicator() ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at bottom
              if (index == displayData.length) {
                if (attemptCount >= maxAttempts) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
                );
              }

              final item = displayData[index];
              // final itemId = item.id ?? index;
              // final isExpanded = expandedItems.contains(itemId);

              return CardWeek(
                name: item.talentName ?? "",
                role: _expandDivisionName(item.division ?? ""),
                date: "",
                nameProduct: item.productName ?? "",
                leads: item.totalLeads.toString(),
                transaksi: item.totalTransaction.toString(),
                cr: convertCR(item.cr ?? 0),
                cbt: item.totalCbt.toString(),
              );
            },
          ));
    });
  }

  // Monthly helper methods
  List<ReportPerformanceMonthlyModel> _getMonthlyDisplayData() {
    return filteredDataMonth;
  }

  bool _shouldShowMonthlyLoadingIndicator() {
    return _hasNextPage;
  }

  String _getMonthlyEmptyStateMessage() {
    if (_selectedMonth == null) {
      return 'Silakan pilih bulan terlebih dahulu';
    }
    return 'Belum ada data performa talent untuk ditampilkan';
  }

  Future<void> _refreshMonthlyData() async {
    setState(() {
      _offset = 0;
      _hasNextPage = true;
      listDataMonth.clear();
      filteredDataMonth.clear();
      attemptCount = 0;
    });

    if (_selectedMonth != null) {
      _loadMonthlyData();
    }
  }

  void _loadMonthlyData() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _offset = 0;
      listDataMonth = [];
      filteredDataMonth = [];
      attemptCount = 0;
      _hasNextPage = true;
    });

    // Convert month name to number
    final monthNumber = _listMonths.indexOf(_selectedMonth ?? '') + 1;

    if (monthNumber > 0) {
      _bloc.add(GetReportPerformanceMonthEvent(
        limit: _limit,
        offset: _offset,
        month: monthNumber,
      ));
    }
  }

  Widget _buildListviewMonth() {
    return BlocConsumer<ReportPerformanceBloc, ReportPerformanceState>(
      listener: (context, state) {
        if (state.status == RequestStatus.empty) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
            _hasNextPage = false;
          });
        } else if (state.status == RequestStatus.failure) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state.status == RequestStatus.success) {
          setState(() {
            _isLoading = false;
            _isLoadingMore = false;

            var newData = state.reportPerformanceMonthly;

            if (_offset == 0) {
              // Reset data for first load
              listDataMonth = newData;
              filteredDataMonth = List.from(newData);
              attemptCount = 0;
            } else {
              // Add data for infinite scroll
              if (newData.isEmpty) {
                attemptCount++;
                if (attemptCount >= maxAttempts) {
                  _hasNextPage = false;
                }
              } else {
                attemptCount = 0;
                listDataMonth.addAll(newData);
                filteredDataMonth = List.from(listDataMonth);
                _offset += _limit;
              }
            }

            // Check if there's more data
            if (newData.length < _limit) {
              _hasNextPage = false;
            }
          });
        }
      },
      builder: (context, state) {
        if (valueTab != 2) {
          return const SizedBox(); // Return empty if not monthly tab
        }

        List<ReportPerformanceMonthlyModel> displayData =
            _getMonthlyDisplayData();

        // Show shimmer loading
        bool shouldShowShimmer = _isLoading &&
            displayData.isEmpty &&
            !_isTabChanging &&
            valueTab == 2;

        if (shouldShowShimmer) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: 10,
            itemBuilder: (context, index) {
              return const CardShimmerReportPerformance();
            },
          );
        }

        // Show empty state
        if (displayData.isEmpty && !_isLoading) {
          return RefreshIndicator(
            onRefresh: _refreshMonthlyData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DsEmptyState(
                    imagePath: 'assets/images/team/empty_state_feed.svg',
                    title: 'Report Performa Kosong',
                    description: _getMonthlyEmptyStateMessage(),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
            onRefresh: _refreshMonthlyData,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: displayData.length +
                  (_shouldShowMonthlyLoadingIndicator() ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at bottom
                if (index == displayData.length) {
                  if (attemptCount >= maxAttempts) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: _isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final item = displayData[index];

                return CardMonth(
                  nameProduct: item.productName ?? "",
                  leads: item.leads?.toString() ?? "0",
                  transaksi: item.transaction?.toString() ?? "0",
                  cr: convertCR(item.cr ?? 0),
                  ontap: () {
                    AppRouter.router
                        .push(PAGES.reportdetailperformance.screenPath, extra: {
                      "detailModel": item.detail,
                      "productName": item.productName,
                    });
                  },
                );
              },
            ));
      },
    );
  }

  Widget _buildDailyFilter() {
    return Row(
      children: [
        Expanded(
          child: DsSearchField(
            controller: _textEditingController,
            hintText: 'Cari Produk dan Nama Talent',
            onChanged: (value) => _onSearchChanged(value),
            onSubmitted: (value) => _onSearchSubmitted(value),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DsSquareIconButton(
          customIcon: SvgPicture.asset(
            'assets/images/superapp/ic_filter.svg',
            width: 20,
            height: 20,
          ),
          isActive: hasDateFilter,
          onTap: () => _showTodayFilter(),
        ),
      ],
    );
  }

  Widget _buildWeeklyFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md3),
            decoration: BoxDecoration(
              color: AppColors.alwaysWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.grey200),
              boxShadow: [
                BoxShadow(
                  color: AppColors.alwaysBlack.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                borderRadius: BorderRadius.circular(AppRadius.md),
                menuMaxHeight: 150.0,
                value: _selectedWeek,
                icon: SvgPicture.asset(
                  'assets/images/ic_arrow_bottom.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.grey600,
                    BlendMode.srcIn,
                  ),
                ),
                hint: const Text(
                  'Pilih Minggu',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.alwaysBlack,
                ),
                items: _listWeek.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedWeek = value;
                  });
                  if (value != null) {
                    _loadWeeklyData();
                  }
                },
                isExpanded: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        DsSquareIconButton(
          customIcon: SvgPicture.asset(
            'assets/images/superapp/ic_filter.svg',
            width: 20,
            height: 20,
          ),
          isActive: hasWeeklyProductFilter,
          onTap: () => _showWeeklyFilter(),
        ),
      ],
    );
  }

  Widget _buildMonthlyFilter() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md3),
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.alwaysBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(AppRadius.md),
          menuMaxHeight: 150.0,
          value: _selectedMonth,
          icon: SvgPicture.asset(
            'assets/images/ic_arrow_bottom.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.grey600,
              BlendMode.srcIn,
            ),
          ),
          hint: const Text(
            'Pilih Bulan',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.alwaysBlack,
          ),
          items: _listMonths.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedMonth = value;
              if (value != null) {
                _loadMonthlyData();
              }
            });
          },
          isExpanded: true,
        ),
      ),
    );
  }

  // IMPROVED - Today filter method
  void _showTodayFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomShowmodalReportPerformanceToday(
        context: context,
        selectedDate: selectedDate,
        value: todayFilterValue,
        textEditor: _textEditingController.text,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          firstDate = value['firstDate'];
          lastDate = value['lastDate'];
          todayFilterValue = value['value'] ?? 0;
          hasDateFilter = todayFilterValue != 0;

          // Clear search when applying date filter if textEditor is empty
          if (value['textEditor'] == '') {
            _textEditingController.clear();
          }
          // Reset pagination variables
          _offset = 0;
          _hasNextPage = true;
          attemptCount = 0;
          listDataToday = [];
          filterListDataToday = [];
          _bloc.add(GetReportPerformanceEvent(
            search: _textEditingController.text,
            startDate: firstDate,
            endDate: lastDate,
            limit: _limit.toString(),
            offset: _offset.toString(),
          ));
        });
      }
    });
  }

  void _showWeeklyFilter() async {
    // Ambil list produk terbaru dari API saat filter dibuka
    final bloc = context.read<ReportPerformanceBloc>();

    profileResponse ??= await pref.getProfileResponse();
    final partnerId = profileResponse?.partnerId.toString() ?? '';

    if (partnerId.isNotEmpty) {
      final previousLength = bloc.state.reportPerformanceProduct.length;
      _bloc.add(GetReportPerformanceProductEvent(
        keyword: '',
        parentId: partnerId,
      ));

      try {
        await bloc.stream
            .firstWhere((state) =>
                state.reportPerformanceProduct.length != previousLength ||
                state.status == RequestStatus.failure)
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        // fallback ke state yang tersedia saat ini
      }
    }

    if (!mounted) return;

    List<ReportPerformanceProductModel> productList =
        bloc.state.reportPerformanceProduct;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomShowmodalReportPerformanceWeek(
        context: context,
        selectedDate: selectedDate,
        value: hasWeeklyProductFilter ? 1 : 0,
        textEditor: _textEditingController.text,
        selectedProductId: selectedProductId,
        listProduct: productList,
      ),
    ).then((value) {
      if (value != null) {
        bool shouldRefresh = false;

        // Handle product selection
        if (value['select_product'] != null) {
          String newProductId = value['select_product'];
          if (selectedProductId != newProductId) {
            setState(() {
              selectedProductId = newProductId;
              hasWeeklyProductFilter =
                  newProductId.isNotEmpty && newProductId != 'null';
            });
            shouldRefresh = true;
          }
        }

        // Only refresh if something changed
        if (shouldRefresh && _selectedWeek != null) {
          _refreshWeeklyData();
        }
      }
    });
  }

  showHiddenButton(int value) {
    setState(() {
      valueTab = value;
    });
  }

// SOLUSI 3: Tambahkan state untuk track tab yang sedang aktif
  bool _isTabChanging = false;

  String convertCR(num number) {
    int numInt = number.floor();
    return numInt.toString();
  }
}
