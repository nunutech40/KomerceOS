import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/features/home/bloc/history_page_bloc.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/tab_button.dart';
import '../../../common/styles.dart';
import '../../../common/utils/loading/shimmer_placeholder_invoice_list.dart';
import '../../invoice/widget/invoice_item.dart';

enum TabState { All, Invoice, Saldo, Penarikan, TopUp }

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with ErrorHandlingMixin {
  TabState _currentTab = TabState.All;
  String dropdownText = 'Saldo'; // default value
  final GlobalKey _menuKey = GlobalKey();
  var _bloc;
  //global bloc detail
  // var _blocDetail;
  // Controller untuk mengelola perilaku scroll
  final _scrollController = ScrollController();
  // Batas data yang akan dimuat dalam satu waktu
  final _limit = 10;
  // Offset untuk pagination
  var _offset = 0;
  // Status loading saat mengambil data tambahan
  bool _isLoadingMore = false;
  // Jumlah percobaan gagal saat mengambil data
  int _failedAttempts = 0;
  // Status apakah masih ada data yang bisa dimuat
  bool _hasMoreData = true;
  // List untuk menyimpan invoice
  List<dynamic> historyTransaction = [];
  // List untuk menyimpan invoice perlu aksi lebih lanjut
  List<dynamic> historyTransactionNeedProcess = [];
  String? transactionType;
  String? checkTransactionType;
  //global id top up
  int toUpId = 0;
  String? statusAccount = "";
  bool _isScrollListenerActive = false; // Flag untuk mengontrol listener

  @override
  void initState() {
    super.initState();

    _initializeBloc();
    loadDataNeedProcess();
    // Tambahkan listener untuk mendeteksi perilaku scroll
    _scrollController.addListener(_onScroll);
    if (historyTransaction.isNotEmpty) {
      _bloc.add(const ClearHistory());
    }
    if (historyTransaction.isEmpty) {
      loadData();
    }
    // Aktifkan listener setelah data selesai dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isScrollListenerActive = true; // Aktifkan listener setelah init
    });
  }

  void _initializeBloc() {
    _bloc = context.read<HistoryPageBloc>();
  }

  void loadDataCeckTransaction(int id) async {
    // Invoke Bloc event after initial frame is rendered
    await _bloc.add(LoadDataDetailTopUpEvent(id: id));
  }

  void loadDataNeedProcess() async {
    final dataNeedProcess =
        await _bloc.add(const TransactionNeedProcessHistoryLoad());
    // If there's new data, add it to invoices.
    if (dataNeedProcess != null && dataNeedProcess.isNotEmpty) {
      historyTransactionNeedProcess.addAll(dataNeedProcess);
    }

    setState(() {}); // Trigger a rebuild
  }

  void loadData() async {
    await _bloc.add(const HomePageDidload());
    try {
      await _bloc.add(TransactionHistoryLoad(
        type: transactionType ?? '',
        limit: _limit,
        offset: _offset,
      ));
    } catch (e) {
      // Handle any other exceptions that might occur
      // print('Error fetching data: $e');
    }
  }

  void _loadMore() async {
    // Check if we're already loading, if there's no more data, or if we've failed too many times
    if (_isLoadingMore || !_hasMoreData || _failedAttempts >= 3) return;

    // Update the offset for the "load more" fetch
    _offset += _limit;
    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1), () async {
      // Fetch more data
      try {
        await _bloc.add(TransactionHistoryLoad(
          type: transactionType ?? '',
          limit: _limit,
          offset: _offset,
        ));
      } catch (e) {
        // Handle any other exceptions that might occur
        // print('Error fetching data: $e');
      }
    });

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (!_isScrollListenerActive) return;
    if (_hasMoreData &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void refreshData() async {
    _offset = 0;
    historyTransaction.clear();
    historyTransactionNeedProcess.clear();

    // Reset variabel ke default
    _failedAttempts = 0;
    _hasMoreData = true;
    setState(() {});
    // await _bloc.add(const RefreshDataEvent());
  }

  // Define the _handleRefresh method
  Future<void> _handleRefresh() async {
    refreshData();
    _updateActiveTab(TabState.All);
  }

  _updateActiveTab(TabState currentTab) async {
    setState(() {
      _offset = 0;
      historyTransaction.clear();
      historyTransactionNeedProcess.clear();
      _hasMoreData = true;
      _failedAttempts = 0;
    });
    await _bloc.add(const ClearHistory());

    switch (currentTab) {
      case TabState.Invoice:
        transactionType = "invoice";
        dropdownText = 'Saldo';
        break;
      case TabState.Penarikan:
        transactionType = "withdrawal";
        break;
      case TabState.TopUp:
        transactionType = "topup";
        break;
      case TabState.All:
      default:
        transactionType = null;
        dropdownText = 'Saldo';
        break;
    }

    if (currentTab == TabState.All) {
      loadDataNeedProcess();
    }

    setState(() {
      loadData();
      _currentTab = currentTab;
    });
  }

  void _showMenu() {
    final popupMenuButtonState = _menuKey.currentState as dynamic;
    popupMenuButtonState?.showButtonMenu();
  }

  void _onDropdownChanged(String? value) {
    TabState selectedTab;
    switch (value) {
      case 'Top Up':
        selectedTab = TabState.TopUp;
        dropdownText = 'Top Up';
        break;
      case 'Penarikan':
        selectedTab = TabState.Penarikan;
        dropdownText = 'Penarikan';
        break;
      case 'Saldo':
        selectedTab = TabState.Saldo;
        dropdownText = 'Saldo';
        break;
      default:
        selectedTab = TabState.All;
        dropdownText = 'Saldo';
        break;
    }
    _updateActiveTab(selectedTab);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat', style: AppTypography.interSemiBold16),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<HistoryPageBloc, HistoryPageState>(
        listener: (context, state) {
          if (state.status == RequestStatus.success &&
              state.profileData != null) {
            statusAccount = state.profileData?.accountStatus ?? "";
          }
          if (state.status == RequestStatus.success &&
              state.transactionHistoryData.isNotEmpty) {
            setState(() {
              historyTransaction.addAll(state.transactionHistoryData);
              _failedAttempts =
                  0; // Reset failed attempts on successful data fetch
            });
          } else if (state.status == RequestStatus.success &&
              state.transactionHistoryData.isEmpty) {
            _failedAttempts++; // Increment failed attempts
            if (_failedAttempts >= 3) {
              setState(() {
                _hasMoreData = false;
              });
            }
          }

          if (state.status == RequestStatus.success &&
              state.transactionNeedHistoryHistoryData.isNotEmpty &&
              historyTransactionNeedProcess.isEmpty) {
            setState(() {
              historyTransactionNeedProcess
                  .addAll(state.transactionNeedHistoryHistoryData);
            });
          }

          if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TabButton(
                      isActive: _currentTab == TabState.All,
                      onPressed: () => _updateActiveTab(TabState.All),
                      text: 'Semua',
                    ),
                    const SizedBox(width: 12.0),
                    TabButton(
                      isActive: _currentTab == TabState.Invoice,
                      onPressed: () => _updateActiveTab(TabState.Invoice),
                      text: 'Invoice',
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: PopupMenuButton<String>(
                          key: _menuKey,
                          onSelected: (value) {
                            _onDropdownChanged(value);
                          },
                          offset: const Offset(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 4.0,
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'Top Up',
                              child: Text('Top Up',
                                  style: AppTypography.regular14
                                      .copyWith(color: primaryColor)),
                            ),
                            PopupMenuItem<String>(
                              value: 'Penarikan',
                              child: Text('Penarikan',
                                  style: AppTypography.regular14
                                      .copyWith(color: primaryColor)),
                            ),
                          ],
                          child: TabButton(
                            isActive: _currentTab == TabState.Penarikan ||
                                _currentTab == TabState.TopUp,
                            onPressed: _showMenu,
                            text: dropdownText,
                            icon: SvgPicture.asset(
                              'assets/images/ic-arrow-down.svg',
                              color: (_currentTab == TabState.Penarikan ||
                                      _currentTab == TabState.TopUp)
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                Expanded(
                  child: historyTransaction.isEmpty &&
                          historyTransactionNeedProcess.isEmpty &&
                          state.status != RequestStatus.loading
                      ? const Center(child: Text("Data Tidak Ada"))
                      : state.status == RequestStatus.loading &&
                              historyTransaction.isEmpty &&
                              historyTransactionNeedProcess.isEmpty
                          ? const ShimmerPlaceholderInvoiceList()
                          : RefreshIndicator(
                              onRefresh: _handleRefresh,
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      historyTransactionNeedProcess
                                                  .isNotEmpty &&
                                              _currentTab == TabState.All
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Text(
                                                "Perlu Aksi Lebih Lanjut",
                                                style: AppTypography.regular16,
                                              ),
                                            )
                                          : Container(),
                                      historyTransactionNeedProcess
                                                  .isNotEmpty &&
                                              _currentTab == TabState.All
                                          ? BlocConsumer<HistoryPageBloc,
                                                  HistoryPageState>(
                                              listener: (context, state) {
                                              if (state.statusDetail ==
                                                      RequestStatus.success &&
                                                  state.dataResponseDetail!
                                                          .transactionPaymentUrl !=
                                                      "" &&
                                                  state.dataResponseDetail!
                                                          .transactionTopupType ==
                                                      "bank_transfer" &&
                                                  checkTransactionType ==
                                                      "topup") {
                                                checkTransactionType = null;
                                                AppRouter.router.pushNamed(
                                                    PAGES
                                                        .bankpayment.screenName,
                                                    queryParameters: {
                                                      'transaction_id': [
                                                        toUpId.toString(),
                                                      ]
                                                    });
                                              } else if (state.statusDetail ==
                                                      RequestStatus.success &&
                                                  state.dataResponseDetail!
                                                          .transactionQrisCode !=
                                                      "" &&
                                                  state.dataResponseDetail!
                                                          .transactionTopupType ==
                                                      "qris" &&
                                                  checkTransactionType ==
                                                      "topup") {
                                                checkTransactionType = null;
                                                AppRouter.router.pushNamed(
                                                    PAGES
                                                        .qrispayment.screenName,
                                                    queryParameters: {
                                                      'transaction_id': [
                                                        toUpId.toString(),
                                                      ]
                                                    });
                                              }
                                            }, builder: (context, statedetail) {
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    historyTransactionNeedProcess
                                                        .length,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      String invoiceId =
                                                          historyTransactionNeedProcess[
                                                                      index]
                                                                  .transactionCode ??
                                                              '0';
                                                      toUpId =
                                                          historyTransactionNeedProcess[
                                                                      index]
                                                                  .transactionId ??
                                                              0;
                                                      checkTransactionType =
                                                          historyTransactionNeedProcess[
                                                                      index]
                                                                  .transactionType ??
                                                              'invoice';
                                                      if (checkTransactionType !=
                                                              'topup' &&
                                                          checkTransactionType !=
                                                              'withdrawal') {
                                                        AppRouter.router
                                                            .pushNamed(
                                                          PAGES
                                                              .invoiceReportSummary
                                                              .screenName,
                                                          queryParameters: {
                                                            'invoiceCode':
                                                                invoiceId,
                                                            'statusAccount':
                                                                statusAccount
                                                          },
                                                        );
                                                      } else if (checkTransactionType !=
                                                              'invoice' &&
                                                          checkTransactionType !=
                                                              'withdrawal') {
                                                        loadDataCeckTransaction(
                                                            toUpId);
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8.0),
                                                        child: InvoiceItem(
                                                            transactionData:
                                                                historyTransactionNeedProcess[
                                                                    index]),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            })
                                          : Container(),
                                      transactionType != null
                                          ? Container()
                                          : const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: Text(
                                                "Transaksi Selesai",
                                                style: AppTypography.regular16,
                                              ),
                                            ),
                                    ],
                                  )),
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                          childCount:
                                              historyTransaction.length +
                                                  (_isLoadingMore ? 1 : 0),
                                          (context, index) {
                                    if (index == historyTransaction.length) {
                                      return const Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 8.0),
                                          Text("Lagi loading...")
                                        ],
                                      );
                                    }

                                    return InkWell(
                                        onTap: () {
                                          String invoiceId =
                                              historyTransaction[index]
                                                      .transactionCode ??
                                                  '0';
                                          String transactionType =
                                              historyTransaction[index]
                                                      .transactionType ??
                                                  'invoice';
                                          if (transactionType != 'topup' &&
                                              transactionType != 'withdrawal') {
                                            AppRouter.router.pushNamed(
                                              PAGES.invoiceReportSummary
                                                  .screenName,
                                              queryParameters: {
                                                'invoiceCode': invoiceId,
                                                'statusAccount': statusAccount
                                              },
                                            );
                                          }
                                        },
                                        child: _currentTab == TabState.All
                                            ? Container(
                                                child: historyTransaction[index]
                                                                .transactionStatus ==
                                                            "completed" ||
                                                        historyTransaction[
                                                                    index]
                                                                .transactionStatus ==
                                                            "canceled" ||
                                                        historyTransaction[
                                                                    index]
                                                                .transactionStatus ==
                                                            "rejected" ||
                                                        historyTransaction[
                                                                    index]
                                                                .transactionStatus ==
                                                            "paid" ||
                                                        historyTransaction[
                                                                    index]
                                                                .transactionStatus ==
                                                            "expired"
                                                    ? Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              width: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10),
                                                          child: InvoiceItem(
                                                            transactionData:
                                                                historyTransaction[
                                                                    index],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                              )
                                            : Container(
                                                child: filterTransactionType(
                                                    _currentTab,
                                                    historyTransaction[index]
                                                        .transactionType,
                                                    index)));
                                  }))
                                ],
                              )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  filterTransactionType(TabState currentTabe, String transactionList, int id) {
    if (currentTabe == TabState.Invoice && transactionList == transactionType) {
      return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InvoiceItem(transactionData: historyTransaction[id])));
    }
    if (currentTabe == TabState.TopUp && transactionList == transactionType) {
      return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InvoiceItem(transactionData: historyTransaction[id])));
    }
    if (currentTabe == TabState.Penarikan &&
        transactionList == transactionType) {
      return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InvoiceItem(transactionData: historyTransaction[id])));
    }
  }
}
