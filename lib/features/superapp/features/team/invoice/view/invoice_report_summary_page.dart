import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/loading_overlay.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_report_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/card_report_invoice.dart';

import '../../../../../../common/enum_status.dart';
import '../../../../../../common/global/router/app_router.dart';
import '../../../../../../common/utils/loading/shimmer_placeholder_invoice_list.dart';

class InvoiceReportSummaryPage extends StatefulWidget {
  final String invoiceId;
  String xenditUrl;
  String? statusAccount;
  String? from;
  InvoiceReportSummaryPage(
      {Key? key,
      required this.invoiceId,
      required this.xenditUrl,
      this.statusAccount,
      this.from})
      : super(key: key);

  @override
  State<InvoiceReportSummaryPage> createState() =>
      _InvoiceReportSummaryPageState();
}

class _InvoiceReportSummaryPageState extends State<InvoiceReportSummaryPage>
    with ErrorHandlingMixin {
  var _bloc;
  @override
  void initState() {
    super.initState();
    _initializeBloc();
    _bloc.add(InvoviceDetailPageDidload(widget.invoiceId));
  }

  void _initializeBloc() {
    _bloc = context.read<InvoiceDetailBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFDF0F1),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: widget.from == 'payment',
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              Strings.label_detail_invoice_payment,
              style:
                  AppTypography.interSemiBold16.copyWith(color: Colors.white),
            ),
            leading: widget.from == 'payment'
                ? Container()
                : IconButton(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/ic-arrow-left-white.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    onPressed: () {
                      AppRouter.router.pop();
                    },
                  ),
          ),
          body: Stack(
            children: [
              // Background image - behind everything
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/team/bg_invoice.png'),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Gradient fade from image to background
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFDF0F1),
                            Color(0xFFFDF0F1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content on top of background
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: BlocBuilder<InvoiceDetailBloc, InvoiceDetailState>(
                    builder: (context, state) =>
                        _buildContentBasedOnState(state),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              BlocConsumer<InvoiceDetailBloc, InvoiceDetailState>(
            listener: (context, state) {
              if (state.statusEvaluation == RequestStatus.success &&
                  state.invoiceCheckEvaluation?.xenditPaymentUrl != null) {
                AppRouter.router.pushNamed(PAGES.paymentmethod.screenName,
                    queryParameters: {
                      'id': [state.invoiceDetail?.invoiceCode],
                      'xenditUrl': [
                        state.invoiceCheckEvaluation?.xenditPaymentUrl
                      ]
                    });
              } else if (state.operation == 'evaluation' &&
                  state.statusEvaluation == RequestStatus.empty &&
                  state.invoiceCheckEvaluation?.xenditPaymentUrl == null) {
                // print('object123 6');
                if (widget.statusAccount == "off") {
                  AppRouter.router.pushNamed(PAGES.paymentmethod.screenName,
                      queryParameters: {
                        'id': [state.invoiceDetail?.invoiceCode],
                        'xenditUrl': [
                          state.invoiceCheckEvaluation?.xenditPaymentUrl
                        ]
                      });
                } else {
                  // print('object123 rate');
                  AppRouter.router.pushNamed(
                    PAGES.rateTalentNotifPage.screenName,
                    queryParameters: {
                      'xenditUrl': [state.invoiceDetail?.xenditPaymentUrl],
                      'invoiceId': [
                        ((state.invoiceDetail?.invoiceId).toString())
                      ],
                      'invoiceCode': [state.invoiceDetail?.invoiceCode]
                    },
                  );
                }
              } else if (state.statusEvaluation == RequestStatus.failure) {
                handleFailureState(context, state, state.message);
              }
            },
            builder: (context, state) {
              if (state.invoiceDetail?.transactionStatus == "unpaid") {
                return _buildUnpaidBottomBar(state);
              }
              if (state.invoiceDetail?.transactionStatus == "canceled" ||
                  state.invoiceDetail?.transactionStatus == "paid" ||
                  state.invoiceDetail?.transactionStatus == "expired") {
                return _buildPaidExpiredBottomBar(state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        BlocBuilder<InvoiceDetailBloc, InvoiceDetailState>(
          builder: (context, state) {
            if (state.isDownloading) {
              return const LoadingOverlay();
            }
            return const SizedBox
                .shrink(); // return an empty container when not loading
          },
        ),
      ],
    );
  }

  /// Bottom bar for unpaid invoices - matches the design mockup
  Widget _buildUnpaidBottomBar(InvoiceDetailState state) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download button - outlined style with icon
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: state.isDownloading
                    ? null
                    : () {
                        context
                            .read<InvoiceDetailBloc>()
                            .add(InvoiceDownloadFile(widget.invoiceId));
                      },
                icon: state.isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      )
                    : const Icon(
                        Icons.file_download_outlined,
                        size: 20,
                        color: Colors.black87,
                      ),
                label: Text(
                  Strings.label_download_payment,
                  style: AppTypography.interSemiBold14.copyWith(
                    color: Colors.black87,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Continue payment button - solid orange rounded
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await _bloc.add(CheckEvalutionEvent(
                      state.invoiceDetail?.invoiceId.toString() ?? ""));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                child: Text(
                  Strings.label_continue_payment,
                  style: AppTypography.interSemiBold14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom bar for paid/expired/canceled invoices
  Widget _buildPaidExpiredBottomBar(InvoiceDetailState state) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed:
                    state.invoiceDetail?.transactionStatus == "expired" ||
                            state.invoiceDetail?.transactionStatus == "canceled"
                        ? null
                        : () {
                            context
                                .read<InvoiceDetailBloc>()
                                .add(InvoiceDownloadFile(widget.invoiceId));
                          },
                icon: state.isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      )
                    : Icon(
                        Icons.file_download_outlined,
                        size: 20,
                        color: state.invoiceDetail?.transactionStatus ==
                                    "expired" ||
                                state.invoiceDetail?.transactionStatus ==
                                    "canceled"
                            ? onlyGray
                            : Colors.black87,
                      ),
                label: Text(
                  Strings.label_download_payment,
                  style: AppTypography.interSemiBold14.copyWith(
                    color: state.invoiceDetail?.transactionStatus ==
                                "expired" ||
                            state.invoiceDetail?.transactionStatus == "canceled"
                        ? onlyGray
                        : Colors.black87,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: state.invoiceDetail?.transactionStatus ==
                                "expired" ||
                            state.invoiceDetail?.transactionStatus == "canceled"
                        ? Colors.grey.shade300
                        : Colors.grey.shade300,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: state.invoiceDetail?.transactionStatus ==
                              "expired" ||
                          state.invoiceDetail?.transactionStatus == "canceled"
                      ? Colors.grey.shade100
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Back button - outline style
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: AppTypography.interSemiBold14.copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// A separate method to decide the widget based on the state
  Widget _buildContentBasedOnState(InvoiceDetailState state) {
    return state.status == RequestStatus.loading &&
            state.operation == 'getInvoiceDetail'
        ? const Padding(
            padding: EdgeInsets.all(24.0),
            child: ShimmerPlaceholderInvoiceList(),
          )
        : (state.invoiceDetail != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 24.0,
                ),
                child: CardReportInvoice(invoiceDetail: state.invoiceDetail),
              )
            : Container()); // Fallback if none of the conditions are met
  }
}
