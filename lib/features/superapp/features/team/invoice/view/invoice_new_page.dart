import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart'
    hide AppTypography;
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/shimmer_placeholder_invoice_list.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/invoice_item.dart';

class InvoiceNewPage extends StatefulWidget {
  const InvoiceNewPage({super.key});

  @override
  State<InvoiceNewPage> createState() => _InvoiceNewPageState();
}

class _InvoiceNewPageState extends State<InvoiceNewPage>
    with ErrorHandlingMixin {
  late InvoiceListBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final int _limit = 10;
  int _offset = 0;
  bool _isLoadingMore = false;
  int _failedAttempts = 0;
  bool _hasMoreData = true;
  bool _isScrollListenerActive = false;

  List<InvoicesDataModel> _invoices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = context.read<InvoiceListBloc>();
    _loadData();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isScrollListenerActive = true;
    });
  }

  void _loadData() async {
    _bloc.add(InvoviceListPageDidload(
        type: 'invoice', limit: _limit, offset: _offset));
  }

  void _refreshData() async {
    _offset = 0;
    _hasMoreData = true;
    _failedAttempts = 0;
    _invoices.clear();
    _bloc.add(const RefreshDataEvent());
    _loadData();
  }

  void _loadMore() async {
    if (_isLoadingMore || !_hasMoreData || _failedAttempts >= 3) return;

    _offset += _limit;
    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1), () {
      _loadData();
    });

    // reset loading flag is handled in bloc listener,
    // but just to mirror reference strictly we'll keep it as is
  }

  void _onScroll() {
    if (!_isScrollListenerActive) return;
    if (_hasMoreData &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: AppBar(
        backgroundColor: AppColors.alwaysWhite,
        elevation: 0,
        title: const Text(
          Strings.label_invoice,
          style: AppTypography.interSemiBold16,
        ),
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
              state.invoicesData != null) {
            if (state.invoicesData!.isNotEmpty) {
              setState(() {
                if (_offset == 0) {
                  _invoices = List.from(state.invoicesData!);
                } else {
                  _invoices.addAll(state.invoicesData!);
                }
                _isLoadingMore = false;
                _failedAttempts = 0;
                if (state.invoicesData!.length < _limit) {
                  _hasMoreData = false;
                }
              });
            } else {
              setState(() {
                _isLoadingMore = false;
                _failedAttempts++;
                if (_failedAttempts >= 3 || _offset == 0) {
                  _hasMoreData = false;
                }
              });
            }
          }
          if (state.status == RequestStatus.failure) {
            setState(() {
              _isLoadingMore = false;
            });
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
                style: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.grey800,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.alwaysWhite,
                  hintText: 'Cari invoice',
                  hintStyle: AppTypography.bodyMdRegular.copyWith(
                    color: AppColors.grey400,
                  ),
                  prefixIcon: null,
                  suffixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.grey400,
                    size: AppSpacing.iconLg,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md3,
                    horizontal: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.grey200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(color: AppColors.primaryBase),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () {
              // Action filter
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.alwaysWhite,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.grey200),
              ),
              child: const Icon(Icons.filter_list,
                  color: AppColors.grey700, size: AppSpacing.iconMd),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(InvoiceListState state) {
    if (state.status == RequestStatus.loading && _invoices.isEmpty) {
      return const ShimmerPlaceholderInvoiceList();
    }

    if (_invoices.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(child: Text(Strings.label_no_data)),
        ],
      );
    }

    final filteredInvoices = _invoices.where((invoice) {
      final type = invoice.transactionType?.toLowerCase();
      if (type != 'invoice' && type != null) return false;
      if (_searchQuery.isEmpty) return true;
      final code = (invoice.invoiceCode ?? '').toLowerCase();
      return code.contains(_searchQuery);
    }).toList();

    final List<InvoicesDataModel> allNeedProcess = state.needProcessData ?? [];
    final actionRequiredList = allNeedProcess.where((invoice) {
      final type = invoice.transactionType?.toLowerCase();
      if (type != 'invoice' && type != null) return false;
      if (invoice.transactionStatus != 'unpaid') return false;
      if (_searchQuery.isEmpty) return true;
      final code = (invoice.invoiceCode ?? '').toLowerCase();
      return code.contains(_searchQuery);
    }).toList();

    final completedList =
        filteredInvoices.where((i) => i.transactionStatus != 'unpaid').toList();

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24.0),
      children: [
        if (actionRequiredList.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Perlu Aksi Lebih Lanjut',
              style: AppTypography.interSemiBold14.copyWith(
                color: AppColors.grey900,
              ),
            ),
          ),
          ...actionRequiredList.map((invoice) => _buildInvoiceCard(invoice)),
          const SizedBox(height: 16),
        ],
        if (completedList.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Transaksi Selesai',
              style: AppTypography.interSemiBold14.copyWith(
                color: AppColors.grey900,
              ),
            ),
          ),
          ...completedList.map((invoice) => _buildInvoiceCard(invoice)),
        ],
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildInvoiceCard(InvoicesDataModel invoice) {
    return InkWell(
      onTap: () {
        String transactionType = invoice.transactionType ?? 'invoice';
        String invoiceId = invoice.invoiceCode ?? '0';
        if (transactionType != 'topup' && transactionType != 'withdrawal') {
          AppRouter.router.pushNamed(
            PAGES.invoiceReportSummary.screenName,
            queryParameters: {
              'invoiceCode': invoiceId,
              'statusAccount': '',
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InvoiceItem(
          dataInvoice: invoice,
        ),
      ),
    );
  }
}
