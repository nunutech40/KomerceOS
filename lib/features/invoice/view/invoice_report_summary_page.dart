import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_icon_text.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/loading_overlay.dart';
import 'package:komtim_partner/features/invoice/bloc/invoice_report_summary_bloc.dart';
import 'package:komtim_partner/features/invoice/widget/card_report_invoice.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/widgets/custom_outline_button.dart';
import '../../../common/utils/loading/shimmer_placeholder_invoice_list.dart';

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
          backgroundColor: primaryColor,
          appBar: AppBar(
            centerTitle: widget.from == 'payment',
            backgroundColor: primaryColor,
            title: Text(
              Strings.label_detail_invoice_payment,
              style:
                  AppTypography.interSemiBold16.copyWith(color: Colors.white),
            ),
            leading: widget.from == 'payment'
                ? Container()
                : IconButton(
                    icon: SvgPicture.asset(
                        'assets/images/ic-arrow-left-white.svg'),
                    onPressed: () {
                      AppRouter.router.pop();
                    },
                  ),
          ),
          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: BlocBuilder<InvoiceDetailBloc, InvoiceDetailState>(
                  builder: (context, state) => _buildContentBasedOnState(state),
                ),
              ),
            ),
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
                return SafeArea(
                  child: Wrap(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: 10,
                        ),
                        child: CustomButtonIconText(
                          text: Strings.label_download_payment,
                          onPressed: () async {
                            context
                                .read<InvoiceDetailBloc>()
                                .add(InvoiceDownloadFile(widget.invoiceId));
                          },
                          color: Colors.white,
                          backGroundColor: primaryColor,
                          colorText: Colors.white,
                          icon:
                              SvgPicture.asset('assets/images/ic-download.svg'),
                          isLoading: state.isDownloading == true,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: 10.0,
                        ),
                        child: CustomButtonIconText(
                          text: Strings.label_continue_payment,
                          onPressed: () async {
                            await _bloc.add(CheckEvalutionEvent(
                                state.invoiceDetail?.invoiceId.toString() ??
                                    ""));
                          },
                          color: Colors.white,
                          colorText: primaryColor,
                          backGroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state.invoiceDetail?.transactionStatus == "canceled" ||
                  state.invoiceDetail?.transactionStatus == "paid" ||
                  state.invoiceDetail?.transactionStatus == "expired") {
                {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        Column(
                          children: [
                            state.invoiceDetail?.transactionStatus ==
                                        "expired" ||
                                    state.invoiceDetail?.transactionStatus ==
                                        "canceled"
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      left: 24.0,
                                      right: 24.0,
                                      bottom: 10.0,
                                    ),
                                    child: const CustomButtonIconText(
                                      text: Strings.label_download_payment,
                                      onPressed: null,
                                      color: onlyGray,
                                      colorText: Colors.white,
                                      backGroundColor: onlyGray,
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      left: 24.0,
                                      right: 24.0,
                                      bottom: 10,
                                    ),
                                    child: CustomButtonIconText(
                                      text: Strings.label_download_payment,
                                      onPressed: () async {
                                        context.read<InvoiceDetailBloc>().add(
                                            InvoiceDownloadFile(
                                                widget.invoiceId));
                                      },
                                      color: Colors.white,
                                      backGroundColor: primaryColor,
                                      colorText: Colors.white,
                                      icon: SvgPicture.asset(
                                          'assets/images/ic-download.svg'),
                                      isLoading: state.isDownloading == true,
                                    ),
                                  ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 21.0,
                                right: 21.0,
                                bottom: 10,
                              ),
                              child: CustomOutlineButton(
                                text: 'Kembali',
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
                                color: primaryColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }
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

// A separate method to decide the widget based on the state
  Widget _buildContentBasedOnState(InvoiceDetailState state) {
    return state.status == RequestStatus.loading &&
            state.operation == 'getInvoiceDetail'
        ? const ShimmerPlaceholderInvoiceList()
        : (state.invoiceDetail != null
            ? SingleChildScrollView(
                child: CardReportInvoice(invoiceDetail: state.invoiceDetail),
              )
            : Container()); // Fallback if none of the conditions are met
  }
}
