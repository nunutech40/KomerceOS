import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_bloc.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_event.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_state.dart';
import 'package:komtim_partner/features/ratetalent/view/web_view_page.dart';

class BankPaymentPages extends StatefulWidget {
  BankPaymentPages({
    Key? key,
    this.transactionId,
  }) : super(key: key);
  // TopupState valueQris;
  int? transactionId;

  @override
  State<BankPaymentPages> createState() => _BankPaymentPagesState();
}

class _BankPaymentPagesState extends State<BankPaymentPages>
    with ErrorHandlingMixin {
  currencyFormat(double nominal) {
    final currencyFormatter = NumberFormat('#,##0', 'ID');
    String hasil = currencyFormatter.format(nominal);
    return hasil;
  }

  CountdownTimerController? controller;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    loadData();
  }

  var _bloc;
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  void _initializeBloc() {
    _bloc = context.read<TopUpBloc>();
  }

  void loadData() async {
    await _bloc.add(LoadDataDetailTopUpEvent(id: widget.transactionId!));
  }

  dateConvert(date) {
    DateTime parseDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat.yMMMd('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  timeConvert(date) {
    DateTime parseDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat.Hm('id');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  timeConvertCountDown(date) {
    DateTime parseDate = DateFormat('yyyy-MM-dd HH:mm:ss', 'id').parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    // dateTimevalue = inputDate;
    int datee = int.parse("${inputDate.millisecondsSinceEpoch + 1000 * 1}");
    return datee;
  }

  String? expired;

  void transactionExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        expired = "Expired";
      });
    });
  }

  textExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        expired = "Expired";
      });
    });
    return Text(expired ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(Strings.label_payment_process,
              style: AppTypography.interSemiBold16),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child:
                BlocConsumer<TopUpBloc, TopupState>(listener: (context, state) {
              if (state.status == RequestStatus.success &&
                  _isLoadingNotifier.value == true) {
                _isLoadingNotifier.value = false;
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (state.status == RequestStatus.failure) {
                handleFailureState(context, state, state.message);
              }
            }, builder: (context, state) {
              int? adminFee =
                  state.dataResponseDetail?.transactionAmountAdmin ?? 0;
              int? nominal = state.dataResponseDetail?.transactionNominal ?? 0;
              int? subNominal = (nominal + adminFee);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                Strings.label_please_continue_payment_process,
                                style: AppTypography.interSemiBold14,
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              const Text(
                                Strings.label_continue_before,
                                style: AppTypography.regular12,
                              ),
                              Text(
                                state.status == RequestStatus.success
                                    ? "${dateConvert(state.dataResponseDetail?.expiredAt.toString())}, ${timeConvert(state.dataResponseDetail?.expiredAt.toString())} WIB."
                                    : "",
                                style: AppTypography.regular12,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: backgroundPrimaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Center(
                                child: state.status == RequestStatus.success
                                    ? CountdownTimer(
                                        onEnd: () {
                                          transactionExpired();
                                        },
                                        endTime: timeConvertCountDown(state
                                            .dataResponseDetail?.expiredAt
                                            .toString()),
                                        widgetBuilder:
                                            (_, CurrentRemainingTime? time) {
                                          if (time == null) {
                                            return textExpired();
                                          }
                                          String format(int num) {
                                            if (num < 10) {
                                              return '0$num';
                                            }
                                            return num.toString();
                                          }

                                          return Text(
                                            '${time.hours == null ? "00" : format(time.hours ?? 0)} : ${time.min == null ? "00" : format(time.min ?? 0)} : ${time.sec == null ? "00" : format(time.sec ?? 0)}',
                                            style: const TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          );
                                        },
                                      )
                                    : const Text(
                                        "",
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              Strings.label_detail_transaction,
                              style: AppTypography.bold16,
                            ),
                          ),
                          Image.asset("assets/images/ic-line-dash.png"),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Invoice:",
                                  style: AppTypography.interSemiBold14,
                                ),
                                Text(
                                  state.dataResponseDetail?.transactionCode ??
                                      "",
                                  style: AppTypography.regular12,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      Strings.label_topup_kmpoin,
                                      style: AppTypography.interSemiBold14,
                                    ),
                                    Text(
                                      "1xRp${currencyFormat(nominal.toDouble())}",
                                      style: AppTypography.regular12,
                                    ),
                                  ],
                                ),
                                Text(
                                  "Rp${currencyFormat(nominal.toDouble())}",
                                  style: AppTypography.regular12,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  Strings.label_service_cost,
                                  style: AppTypography.interSemiBold14,
                                ),
                                Text(
                                  "Rp${currencyFormat(adminFee.toDouble())}",
                                  style: AppTypography.regular12,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Subtotal",
                                  style: AppTypography.regular12,
                                ),
                                Text(
                                  "Rp${currencyFormat(subNominal.toDouble())}",
                                  style: AppTypography.regular12,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  Strings.label_total,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Rp${currencyFormat(state.dataResponseDetail?.transactionTotal?.toDouble() ?? 0)}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    expired == "Expired"
                        ? Container()
                        : Center(
                            child: InkWell(
                              onTap: () {
                                cancelTopUpConfirm();
                              },
                              child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 25),
                                  child: const Text(
                                    Strings.label_cancel_transaction,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: errorColor),
                                  )),
                            ),
                          )
                  ],
                ),
              );
            }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BlocConsumer<TopUpBloc, TopupState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return BottomElevationContainer(
                    status: true,
                    elevationHeight: 95,
                    onTap: () {
                      if (expired == "Expired") {
                        _bloc.add(CancelTopUpEvent(id: widget.transactionId!));
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      } else {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                    content: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WebViewPage(
                                url: state.dataResponseDetail
                                        ?.transactionPaymentUrl ??
                                    "")));
                      },
                      child: const Center(
                        child: Text(Strings.label_continue_the_payment,
                            style: AppTypography.medium14White),
                      ),
                    ),
                    // );
                    // }),
                  );
                }),
          )
        ],
      ),
    );
  }

  Future<bool> cancelTopUpConfirm() async {
    return await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => WillPopScope(
            onWillPop: () async => true,
            child: ValueListenableBuilder<bool>(
                valueListenable: _isLoadingNotifier,
                builder: (context, isLoading, child) {
                  return AlertDialog(
                      backgroundColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: SvgPicture.asset(
                                  "assets/images/ic-alert.svg"),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                child: Text(
                                  Strings.dialog_cancel_transaction,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.interSemiBold14,
                                ),
                              ),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: InkWell(
                                          onTap: () {
                                            _isLoadingNotifier.value = true;
                                            _bloc.add(CancelTopUpEvent(
                                                id: widget.transactionId!));
                                          },
                                          child: _isLoadingNotifier.value ==
                                                  false
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 9, bottom: 9),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: errorColor),
                                                  child: const Center(
                                                    child: Text(
                                                      Strings.label_yes,
                                                      style: TextStyle(
                                                          color: lightGray),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 9, bottom: 9),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: onlyGray,
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      Strings.label_yes,
                                                    ),
                                                  ),
                                                )),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 9, bottom: 9),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(width: 0.7),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              Strings.label_no,
                                              style:
                                                  AppTypography.interRegular12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ));
                }),
          ),
        ) ??
        false;
  }
  // );
}

// ignore: must_be_immutable
class BottomElevationContainer extends StatelessWidget {
  final double elevationHeight;
  final Widget content;
  bool? status;
  VoidCallback onTap;

  BottomElevationContainer(
      {super.key,
      required this.elevationHeight,
      required this.content,
      required this.status,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: math.max(0, MediaQuery.of(context).viewInsets.bottom),
            left: 0,
            right: 0,
            height: elevationHeight,
            child: status == false
                ? Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // Change the background color as needed
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                              0, 0), // Customize the shadow properties
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        color: Colors
                            .white, // Change the background color as needed
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 45,
                            decoration: BoxDecoration(
                                color: onlyGray,
                                borderRadius: BorderRadius.circular(10)),
                            child: content),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // Change the background color as needed
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                              0, 0), // Customize the shadow properties
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        color: Colors
                            .white, // Change the background color as needed
                        child: InkWell(
                          onTap: onTap,
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 45,
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: content),
                        ),
                      ),
                    ),
                  )),
      ],
    );
  }
}
