import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/utils/loading/shimmer_placeholder_invoice_list.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/bottom_sheet_filter.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_shopping.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage>
    with ErrorHandlingMixin {
  String filterStatus = 'Semua';
  String filterDate = 'Semua';
  final _limit = 10;
  var _offset = 0;
  final _controller = TextEditingController();
  String _searchQuery = '';
  List<ShoppingListDataModel> shoppingListData = [];
  var _bloc;
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _failedAttempts = 0;
  bool _hasMoreData = true;
  bool isToday = false;
  bool isSeventDay = false;
  bool isAllDate = false;

  String _type(String type) {
    switch (type) {
      case 'Semua':
        return '';
      case 'Diajukan':
        return 'requested';
      case 'Disetujui':
        return 'approved';
      case 'Ditolak':
        return 'rejected';
      case 'Dibatalkan':
        return 'canceled';
      case 'Selesai':
        return 'completed';
      case 'Hari ini':
        return 'today';
      case '7 Hari Terakhir':
        return 'seventDay';
      default:
        return '';
    }
  }

  String _getTodayDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  String _getLastSeventDate() {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
    String formattedDate = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    return formattedDate;
  }

  String _checkDateToday(String type) {
    switch (type) {
      case 'Semua':
        return '';
      case 'Hari ini':
        return _getTodayDate();
      case '7 Hari Terakhir':
        return _getLastSeventDate();
      default:
        return '';
    }
  }

  String _checkDate(String type) {
    switch (type) {
      case 'Semua':
        return '';
      case 'Hari ini':
        return _getTodayDate();
      case '7 Hari Terakhir':
        return _getTodayDate();
      default:
        return '';
    }
  }

  void resetFilter() {
    _offset = 0;
    shoppingListData.clear();
  }

  void _statusClicked(String status) async {
    filterStatus = status;
    resetFilter();
    await _bloc.add(GetShoppingListEvent(
        offset: _offset,
        limit: _limit,
        status: _type(filterStatus),
        startDate: _checkDateToday(filterDate),
        endDate: _checkDate(filterDate),
        keyword: _searchQuery));
  }

  void _resetClicked() {
    filterStatus = 'Semua';
    filterDate = 'Semua';
    resetFilter();
    loadData();
  }

  void _dateClicked(String date) {
    filterDate = date;
    resetFilter();
    _bloc.add(GetShoppingListEvent(
        offset: _offset,
        limit: _limit,
        status: _type(filterStatus),
        startDate: _checkDateToday(filterDate),
        endDate: _checkDate(filterDate),
        keyword: _searchQuery));
  }

  void _detail(int id) {
    AppRouter.router.push('${PAGES.detailShoppingPage.screenPath}?id=$id');
  }

  void refreshData() async {
    _offset = 0;
    shoppingListData.clear();
    _hasMoreData = true;
    _failedAttempts = 0;

    await _bloc.add(const RefreshDataEvent());
  }

  Future<void> _handleRefresh() async {
    refreshData();
    loadData();
  }

  void _initializeBloc() {
    _bloc = context.read<ShoppingBloc>();
  }

  void loadData() async {
    await _bloc.add(GetShoppingListEvent(
        offset: _offset,
        limit: _limit,
        status: _type(filterStatus),
        startDate: _checkDateToday(filterDate),
        endDate: _checkDate(filterDate),
        keyword: _searchQuery));
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMoreData || _failedAttempts >= 3) return;
    _offset += _limit;

    setState(() {
      _isLoadingMore = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    loadData();

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (_hasMoreData &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  List<ShoppingListDataModel> moveSelectedToTop(
      List<ShoppingListDataModel> talents) {
    return talents;
  }

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppRouter.router.go(PAGES.main.screenPath);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: DsAppBar(
          title: Strings.label_data_shopping,
          onBackPressed: () {
            AppRouter.router.go(PAGES.main.screenPath);
          },
        ),
        body: BlocConsumer<ShoppingBloc, ShoppingState>(
            listener: (context, state) {
          if (state.status == RequestStatus.success &&
              state.shoppingList.isNotEmpty) {
            setState(() {
              shoppingListData.addAll(state.shoppingList);
              _failedAttempts = 0;
            });
          } else if (state.shoppingList.isEmpty) {
            _failedAttempts++;
            if (_failedAttempts >= 3) {
              setState(() {
                _hasMoreData = false;
              });
            }
          }

          if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        }, builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DsSearchField(
                          controller: _controller,
                          hintText: Strings.label_search_lead_name,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              shoppingListData.clear();
                              if (value == "") {
                                _bloc.add(GetShoppingListEvent(
                                    offset: _offset,
                                    limit: _limit,
                                    status: _type(filterStatus),
                                    startDate: _checkDateToday(filterDate),
                                    endDate: _checkDate(filterDate),
                                    keyword: _searchQuery));
                                _hasMoreData = true;
                              } else {
                                Future.delayed(
                                    const Duration(seconds: 2),
                                    () => _bloc.add(GetShoppingListEvent(
                                        offset: _offset,
                                        limit: _limit,
                                        status: _type(filterStatus),
                                        startDate: _checkDateToday(filterDate),
                                        endDate: _checkDate(filterDate),
                                        keyword: _searchQuery)));
                                _hasMoreData = true;
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      DsSquareIconButton(
                        customIcon: SvgPicture.asset(
                          'assets/images/superapp/ic_filter.svg',
                          width: 20,
                          height: 20,
                        ),
                        isActive:
                            filterStatus != 'Semua' || filterDate != 'Semua',
                        onTap: () {
                          bottomSheetFilter(context, filterStatus, filterDate,
                              onStatusClicked: _statusClicked,
                              onDateClicked: _dateClicked,
                              onResetClicked: _resetClicked);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: shoppingListData.isEmpty &&
                          state.status != RequestStatus.loading
                      ? _searchQuery.isEmpty
                          ? const DsEmptyState(
                              imagePath:
                                  'assets/images/team/empty_state_feed.svg',
                              title: 'Tidak Ada Data Ditemukan',
                              description:
                                  'Data belanja akan muncul di halaman ini',
                            )
                          : const DsEmptyState(
                              imagePath:
                                  'assets/images/team/empty_state_feed.svg',
                              title: 'Tidak Ada Data Ditemukan',
                              description:
                                  'Data belanja akan muncul di halaman ini',
                            )
                      : state.status == RequestStatus.loading &&
                              shoppingListData.isEmpty
                          ? const ShimmerPlaceholderInvoiceList()
                          : RefreshIndicator(
                              onRefresh: _handleRefresh,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: shoppingListData.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == shoppingListData.length) {
                                    return const Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 4.0),
                                        Text("Loading...")
                                      ],
                                    );
                                  }
                                  return InkWell(
                                    child: ItemShopping(
                                      shopping: shoppingListData[index],
                                      onPressed: _detail,
                                    ),
                                  );
                                },
                              ),
                            )),
            ],
          );
        }),
      ),
    );
  }
}
