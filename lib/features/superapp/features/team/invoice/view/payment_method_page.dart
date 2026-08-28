import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/mixin/pop_up_pin_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/confirmation_dialog_payment_topup.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_icon_text.dart';
import 'package:komtim_partner/common/global/widgets/custom_drop_down.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:komtim_partner/features/ratetalent/view/web_view_page.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/payment_method_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/bottom_sheet_balance.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/radio_button_payment_method.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/topup_button.dart';

class PaymentMethodPage extends StatefulWidget {
  String id;
  String xenditUrl;
  PaymentMethodPage({Key? key, required this.id, required this.xenditUrl})
      : super(key: key);
  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage>
    with ErrorHandlingMixin, PopUpPin {
  var bloc;
  String selectedMethod = '';
  bool isTopup = false;
  bool isSetPin = true;
  InvoiceDetailModel? detail;
  ProfileModel? profileData;
  DashboardBalanceDataModel? balanceData;
  String? typeCheckTrasactionStatus;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    loadData();
  }

  void _initializeBloc() {
    bloc = context.read<PaymentMethodBloc>();
  }

  void loadData() async {
    await bloc.add(const GetProfileEvent());
    await bloc.add(const CheckPinEvent());
    await bloc.add(InvoiceDetailEvent(invoiceId: widget.id));
    isTopUp();
  }

  void handlePaymentButtonLogic() {
    debugPrint('isSetPin $isSetPin');
    if (selectedMethod != '' && selectedMethod == 'kompoint') {
      if (isTopUp()) {
        setState(() {
          checkTopUp('topup');
        });
      } else {
        if (isSetPin) {
          if ((detail?.amountTotal ?? 0) >
              (profileData?.kmPoin ?? 0) - (balanceData?.idealBalance ?? 0)) {
            showCustomBottomSheet(context: context, type: 1, data: balanceData);
          } else if ((detail?.amountTotal ?? 0) >
              (profileData?.kmPoin ?? 0) - (balanceData?.onWithdrawl ?? 0)) {
            showCustomBottomSheet(context: context, type: 2, data: balanceData);
          } else if ((detail?.amountTotal ?? 0) >
              (profileData?.kmPoin ?? 0) -
                  (balanceData?.idealBalance ?? 0) -
                  (balanceData?.onWithdrawl ?? 0)) {
            showCustomBottomSheet(context: context, type: 3, data: balanceData);
          } else {
            AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
              'pinType': 'verifyPin',
              'doJobFor': 'payment',
              'invoiceId': widget.id,
              'statusA': profileData?.accountStatus
            });
          }
        } else {
          CustomDropDown.myWidgetKey.currentState?.closeOverlay();
          showPopUpNotYetSetPin(
            context,
            Strings.label_not_create_pin_yet,
            Strings.dialog_use_pin_to_protect,
            'assets/images/ilustrated-setpin.svg',
            Strings.label_create_pin,
            onButtonPressed: showPopUp,
          );
        }
      }
    } else if (selectedMethod != '' && selectedMethod == 'bank') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WebViewPage(url: widget.xenditUrl)));
    }
  }

  void showPopUp() {
    AppRouter.router
        .push(PAGES.pinPage.screenPath, extra: {'pinType': 'setPin'});
    Navigator.of(context).pop();
  }

  void showCustomBottomSheet({
    required BuildContext context,
    required int type,
    required DashboardBalanceDataModel? data,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetBalance(type: type, data: data),
    );
  }

  checkTopUp(String type) async {
    typeCheckTrasactionStatus = type;
    await bloc.add(LoadDataCecktransactionTopUpEvent(
        typeCheckTrasaction: typeCheckTrasactionStatus ?? ''));
  }

  bool isTopUp() {
    if ((detail?.amountTotal ?? 0) <= (profileData?.kmPoin ?? 0)) {
      return false;
    } else {
      return true;
    }
  }

  showInformationPayment(
      BuildContext context, String? idTrancaction, String? typePayment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogNeedProsessPaymentTopUp(
            idTrancaction: idTrancaction, typePayment: typePayment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
      if (state.status == RequestStatus.success &&
          state.operation == 'checkPinExist') {
        if (state.pinData?.isExist ?? false) {
          isSetPin = true;
        } else {
          isSetPin = false;
        }
      } else if (state.status == RequestStatus.success &&
          state.operation == 'getInvoiceDetail') {
        detail = state.invoiceDetail;
      } else if (state.status == RequestStatus.success &&
          state.operation == 'getProfile') {
        profileData = state.profileData;

        bloc.add(GetBalanceAnalyticsEvent(id: profileData?.partnerId));
      } else if (state.status == RequestStatus.success &&
          state.operation == 'getBalanceAnalytics') {
        balanceData = state.balanceData;
      }
      if (state.status == RequestStatus.success &&
          state.detailTopup?.transactionTopupType == "bank_transfer" &&
          state.detailTopup?.transactionType == "topup" &&
          typeCheckTrasactionStatus == 'topup') {
        showInformationPayment(
            context,
            state.detailTopup?.transactionId.toString() ?? "",
            state.detailTopup?.transactionTopupType);
      } else if (state.status == RequestStatus.success &&
          state.detailTopup?.transactionTopupType == "qris" &&
          state.detailTopup?.transactionType == "topup" &&
          typeCheckTrasactionStatus == 'topup') {
        showInformationPayment(
            context,
            state.detailTopup?.transactionId.toString() ?? "",
            state.detailTopup?.transactionTopupType);
      } else if (state.status == RequestStatus.empty &&
          typeCheckTrasactionStatus == 'topup') {
        AppRouter.router.pushNamed(
          PAGES.topuppages.screenName,
        );
      } else if (state.status == RequestStatus.failure) {
        handleFailureState(context, state, state.message);
      }
    }, builder: (context, state) {
      return Stack(
        children: [
          Scaffold(
              backgroundColor: const Color(0xFFFDF0F1),
              extendBodyBehindAppBar: true,
              appBar: const DsAppBar(
                title: 'Metode Pembayaran',
                backgroundColor: Colors.transparent,
                containerLeadingColor: AppColors.alwaysWhite,
                textColor: AppColors.alwaysBlack,
                iconColor: AppColors.alwaysBlack,
              ),
              body: Stack(
                children: [
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
                              image: AssetImage(
                                  'assets/images/team/bg_invoice.png'),
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
                  SafeArea(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Total yang harus dibayar:',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: black0A,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                CurrencyFormat.convertToIdr(
                                    detail?.amountTotal ?? 0, 0),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              const Divider(height: 30, thickness: 1),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Pilih Metode Pembayaran: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: black0A),
                                ),
                              ),
                              const SizedBox(height: 24),
                              PaymentMethodRadio(
                                kompayBalance: profileData?.kmPoin ?? 0,
                                isKompayBalanceSufficient:
                                    (profileData?.kmPoin ?? 0) >=
                                        (detail?.amountTotal ?? 0),
                                onChanged: (selected) {
                                  selectedMethod = selected;
                                },
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              isTopUp()
                                  ? TopUpButton(
                                      onPressed: () {
                                        checkTopUp('topup');
                                      },
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 24.0,
                              bottom: 10.0,
                            ),
                            child: CustomButtonIconText(
                              text: 'Bayar Sekarang',
                              onPressed: () async {
                                handlePaymentButtonLogic();
                              },
                              color: Colors.white,
                              colorText: Colors.white,
                              backGroundColor: primaryColor,
                            )),
                        const SizedBox(
                          height: 56,
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ],
      );
    });
  }
}
