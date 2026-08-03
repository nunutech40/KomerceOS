import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';

import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import '../../../../../../common/enum_status.dart';
import '../../../../../../common/utils/loading/shimmer_placeholder_invoice_list.dart';
import '../widget/invoice_item.dart';

class InvoiceListPage extends StatefulWidget {
  String? statusAccount;
  InvoiceListPage({Key? key, this.statusAccount}) : super(key: key);

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage>
    with ErrorHandlingMixin {
  // Inisialisasi BLoC untuk mengelola data invoice
  var _bloc;
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
  List<dynamic> invoices = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi BLoC dan muat data awal
    _initializeBloc();
    loadData();
    // Tambahkan listener untuk mendeteksi perilaku scroll
    _scrollController.addListener(_onScroll);
  }

  // Method untuk inisialisasi BLoC
  void _initializeBloc() {
    _bloc = context.read<InvoiceListBloc>();
  }

  void loadData() async {
    final newData = await _bloc.add(InvoviceListPageDidload(
        type: 'active', limit: _limit, offset: _offset));
    if (!mounted) return;

    // If there's new data, add it to invoices.
    if (newData != null && newData.isNotEmpty) {
      invoices.addAll(newData);
    }

    // Check if there's more data to be fetched.
    if (newData.length < _limit) {
      _hasMoreData = false;
      if (_offset != 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Data sudah habis")));
      }
    } else {
      _hasMoreData = true;
    }

    setState(() {}); // Trigger a rebuild
  }

  // Method untuk memuat ulang data dari awal
  void refreshData() async {
    // Reset offset dan kosongkan list invoice
    _offset = 0;
    invoices.clear();

    // Reset variabel ke default
    _hasMoreData = true;
    _failedAttempts = 0;

    await _bloc.add(const RefreshDataEvent());
    loadData();
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
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Fetch more data
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

  // Method untuk menangani refresh manual oleh user
  Future<void> _handleRefresh() async {
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.label_invoice,
            style: AppTypography.interSemiBold16),
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
          onPressed: () {
            AppRouter.router.pop();
          },
        ),
      ),
      body: BlocConsumer<InvoiceListBloc, InvoiceListState>(
        listener: (context, state) {
          if (state.status == RequestStatus.success &&
              state.invoicesData != null &&
              state.invoicesData!.isNotEmpty) {
            setState(() {
              invoices.addAll(state.invoicesData!);
              _failedAttempts =
                  0; // Reset failed attempts on successful data fetch
            });
          } else if (state.invoicesData == null ||
              state.invoicesData!.isEmpty) {
            _failedAttempts++; // Increment failed attempts
            if (_failedAttempts >= 3) {
              setState(() {
                _hasMoreData = false;
              });
            }
          }

          if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) {
          if (invoices.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: invoices.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == invoices.length) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8.0),
                        Text(Strings.label_loading)
                      ],
                    );
                  }

                  return InkWell(
                    onTap: () {
                      String transactionType =
                          invoices[index].transactionType ?? 'invoice';
                      String invoiceId = invoices[index].invoiceCode ?? '0';
                      String statusAccount = widget.statusAccount ?? "";
                      if (transactionType != 'topup' &&
                          transactionType != 'withdrawal') {
                        AppRouter.router.pushNamed(
                          PAGES.invoiceReportSummary.screenName,
                          queryParameters: {
                            'invoiceCode': invoiceId,
                            'statusAccount': statusAccount
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      child: InvoiceItem(
                        dataInvoice: invoices[index],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            );
          } else if (state.status == RequestStatus.loading) {
            return const ShimmerPlaceholderInvoiceList();
          } else {
            return const Center(child: Text(Strings.label_no_data));
          }
        },
      ),
    );
  }
}
