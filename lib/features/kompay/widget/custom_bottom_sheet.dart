import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_bloc.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_event.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_state.dart';
import 'package:komtim_partner/features/ratetalent/view/web_view_page.dart';

class CustomBottomSheet extends StatefulWidget {
  String? nominal;
  String? jenistf;
  CustomBottomSheet({super.key, required this.nominal, required this.jenistf});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with ErrorHandlingMixin {
  bool? loadingTopUp = false;
  var _bloc;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    _bloc = context.read<TopUpBloc>();
  }

  //handleListener TopUpState
  handleListenerTopup(TopupState state) {
    if (state.dataTopUpBank?.transactionPaymentUrl != '' &&
        widget.jenistf == "Bank") {
      if (state.status == RequestStatus.success) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WebViewPage(
                url: state.dataTopUpBank?.transactionPaymentUrl ?? "")));
      } else if (state.status == RequestStatus.failure) {
        loadingTopUp = false;
        handleFailureState(context, state, state.message);
      }
    } else if (state.dataResponseQris?.transactionCode != '' &&
        widget.jenistf == "QRIS") {
      if (state.status == RequestStatus.success) {
        AppRouter.router
            .pushNamed(PAGES.qrispayment.screenName, queryParameters: {
          'transaction_id': [
            state.dataResponseQris?.transactionId.toString(),
          ],
          'accessFrom': ['topup']
        });
      } else if (state.status == RequestStatus.failure) {
        handleFailureState(context, state, state.message);
        loadingTopUp = false;
      }
    }
  }

  currencyFormat(double nominal) {
    final currencyFormatter = NumberFormat('#,##0', 'ID');
    String hasil = currencyFormatter.format(nominal);
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TopUpBloc, TopupState>(
        listener: (context, TopupState state) {
      handleListenerTopup(state);
    }, builder: (context, TopupState state) {
      return Container(
          height: 360,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Center(child: Image.asset("assets/images/retangle.png")),
              ),
              const Center(
                  child: Text(Strings.label_confirm_payment,
                      style: AppTypography.semiBold14)),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(Strings.label_payment_method_full,
                        style: AppTypography.interRegular14),
                    Text('Transfer ${widget.jenistf}',
                        style: AppTypography.semiBold14)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(Strings.label_nominal_topup,
                        style: AppTypography.interRegular14),
                    Text(
                        'Rp${currencyFormat(double.parse(widget.nominal ?? ""))}',
                        style: AppTypography.semiBold14)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(Strings.label_service_cost,
                        style: AppTypography.interRegular14),
                    widget.jenistf == "QRIS"
                        ? const Text(Strings.label_free,
                            style: AppTypography.textColorGreen)
                        : int.parse(widget.nominal ?? "") > 500000 &&
                                widget.jenistf == "Bank"
                            ? const Text(Strings.label_free,
                                style: AppTypography.textColorGreen)
                            : Text('Rp${currencyFormat(double.parse("1000"))}',
                                style: AppTypography.semiBold14)
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Center(
                    child: Divider(
                  color: e2Gray,
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(Strings.label_total_bill,
                        style: AppTypography.interRegular14),
                    widget.jenistf == "QRIS"
                        ? Text(
                            'Rp${currencyFormat(double.parse(widget.nominal ?? ""))}',
                            style: AppTypography.semiBold14)
                        : int.parse(widget.nominal ?? "") < 500001 &&
                                widget.jenistf == "Bank"
                            ? Text(
                                'Rp${currencyFormat(double.parse((int.parse(widget.nominal ?? "") + 1000).toString()))}',
                                style: AppTypography.semiBold14)
                            : Text(
                                'Rp${currencyFormat(double.parse(widget.nominal ?? ""))}',
                                style: AppTypography.semiBold14)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 70,
                ),
                child: Container(
                  color: Colors.white, // Change the background color as needed
                  child: loadingTopUp == false
                      ? InkWell(
                          onTap: () async {
                            if (widget.jenistf == "QRIS") {
                              loadingTopUp = true;
                              await _bloc.add(TopUpButtonPressedQrisEvent(
                                  nominal: widget.nominal ?? ""));
                              setState(() {});
                            } else {
                              loadingTopUp = true;
                              await _bloc.add(TopUpButtonPressedEvent(
                                  nominal: widget.nominal ?? "",
                                  jenisTf: widget.jenistf ?? ""));
                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Center(
                              child: Text(Strings.label_pay,
                                  style: AppTypography.medium14White),
                            ),
                          ))
                      : Container(
                          color: Colors
                              .white, // Change the background color as needed
                          child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  color: onlyGray,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text(Strings.label_pay,
                                    style: AppTypography.medium14White),
                              ))),
                ),
              )
            ],
          ));
    });
  }
}
