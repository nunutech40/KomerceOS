import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_event.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/bloc/report_performance_state.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_detail_month.dart';

class DetailReportPerformanceMonthPages extends StatefulWidget {
  final List<DetailModel>? detailModel;
  final List<ReportPerformanceModel>? rawDetailModel;
  final String? startDate;
  final String? endDate;
  final String productName;
  const DetailReportPerformanceMonthPages(
      {super.key,
      required this.detailModel,
      this.rawDetailModel,
      this.startDate,
      this.endDate,
      required this.productName});

  @override
  State<DetailReportPerformanceMonthPages> createState() =>
      _DetailReportPerformanceMonthPagesState();
}

class _DetailReportPerformanceMonthPagesState
    extends State<DetailReportPerformanceMonthPages> {
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _offset = widget.rawDetailModel?.length ?? 0;
    _scrollController.addListener(_loadMore);
  }

  void _loadMore() {
    if (_loadingMore ||
        !_hasMore ||
        widget.startDate == null ||
        widget.endDate == null ||
        !(_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200)) {
      return;
    }

    _loadingMore = true;
    context.read<ReportPerformanceBloc>().add(
          GetReportPerformanceMonthlyDetailEvent(
            limit: '10',
            offset: _offset.toString(),
            startDate: widget.startDate!,
            endDate: widget.endDate!,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
              child: BlocBuilder<ReportPerformanceBloc, ReportPerformanceState>(
            builder: (context, state) {
              final rawData = state.reportPerformanceMonthlyDetail
                  .where((data) => data.productName == widget.productName)
                  .toList();
              if (_loadingMore) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _offset = state.reportPerformanceMonthlyDetail.length;
                      _loadingMore = false;
                      _hasMore = state.reportPerformanceMonthlyDetailHasMore;
                    });
                  }
                });
              }
              final useRaw = rawData.isNotEmpty;
              return ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount:
                    useRaw ? rawData.length : widget.detailModel?.length ?? 0,
                itemBuilder: (context, index) {
                  if (useRaw) {
                    final data = rawData[index];
                    return CardDetailMonth(
                      name: data.talentName ?? '-',
                      role: data.division ?? '-',
                      nameProduct: widget.productName,
                      leads: data.leads?.toString() ?? '-',
                      transaksi: data.transaction?.toString() ?? '-',
                      cbt: data.cb?.toString() ?? '-',
                      cr: convertCR(data.cr ?? 0),
                    );
                  }
                  final data = widget.detailModel?[index];
                  return CardDetailMonth(
                    name: data?.talentName ?? '-',
                    role: data?.division ?? '-',
                    nameProduct: widget.productName,
                    leads: data?.totalLeads.toString() ?? '-',
                    transaksi: data?.totalTransactions.toString() ?? '-',
                    cbt: data?.totalCbt.toString() ?? '-',
                    cr: convertCR(data?.closingRate ?? 0),
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return DsAppBar(title: widget.productName);
  }

  String convertCR(num number) {
    int numInt = number.floor();
    return numInt.toString();
  }
}
