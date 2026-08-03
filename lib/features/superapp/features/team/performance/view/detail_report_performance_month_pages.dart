import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/features/superapp/features/team/performance/widget/card_detail_month.dart';

class DetailReportPerformanceMonthPages extends StatefulWidget {
  final List<DetailModel>? detailModel;
  final String productName;
  const DetailReportPerformanceMonthPages(
      {super.key, required this.detailModel, required this.productName});

  @override
  State<DetailReportPerformanceMonthPages> createState() =>
      _DetailReportPerformanceMonthPagesState();
}

class _DetailReportPerformanceMonthPagesState
    extends State<DetailReportPerformanceMonthPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: widget.detailModel?.length ?? 0,
            itemBuilder: (context, index) {
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
          ))
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(widget.productName, style: AppTypography.interSemiBold16),
      centerTitle: true,
      leading: IconButton(
        icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
        onPressed: () => AppRouter.router.pop(),
      ),
    );
  }

  String convertCR(num number) {
    int numInt = number.floor();
    return numInt.toString();
  }
}
