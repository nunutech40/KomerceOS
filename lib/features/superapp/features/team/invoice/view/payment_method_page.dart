import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_result_page.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_button.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/mixin/pop_up_pin_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_icon_text.dart';
import 'package:komtim_partner/common/global/widgets/custom_drop_down.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/check_bill_model.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/payment_method_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/bottom_sheet_balance.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/radio_button_payment_method.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/topup_button.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_invoice_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/expire_qrcode_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/barcode_qris_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/topup_page.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/web_view_page.dart';
import 'package:lottie/lottie.dart';

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
  Route? _loadingRoute;
  bool _isNavigating = false; // Guard navigasi ganda

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
        _checkActiveBillAndNavigate();
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

  void _showLoading() {
    if (_loadingRoute != null) return;
    _loadingRoute = DialogRoute(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Lottie.asset(
          'assets/json/loading-superapp.json',
          width: 80,
          height: 80,
        ),
      ),
    );
    Navigator.of(context, rootNavigator: true).push(_loadingRoute!);
  }

  void _hideLoading() {
    if (_loadingRoute != null) {
      if (_loadingRoute!.isActive) {
        Navigator.of(context, rootNavigator: true).removeRoute(_loadingRoute!);
      }
      _loadingRoute = null;
    }
  }

  void _checkActiveBillAndNavigate() {
    if (_isNavigating) return; // Prevent double tap
    bloc.add(const CheckActiveBillEvent());
  }

  void _navigateToActiveBillFromData(CheckBillModel data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocListener(
          listeners: [
            BlocListener<ExpireQrcodeBloc, ExpireQrcodeState>(
              listener: (context, expireState) {
                if (expireState is ExpireQrcodeLoading) {
                  _showLoading();
                } else if (expireState is ExpireQrcodeSuccess) {
                  _hideLoading();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopupPage(),
                    ),
                  );
                } else if (expireState is ExpireQrcodeError) {
                  _hideLoading();
                  if (!expireState.isServerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(expireState.message)),
                    );
                  }
                }
              },
            ),
            BlocListener<ExpireInvoiceBloc, ExpireInvoiceState>(
              listener: (context, expireState) {
                if (expireState is ExpireInvoiceLoading) {
                  _showLoading();
                } else if (expireState is ExpireInvoiceSuccess) {
                  _hideLoading();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopupPage(),
                    ),
                  );
                } else if (expireState is ExpireInvoiceError) {
                  _hideLoading();
                  if (!expireState.isServerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(expireState.message)),
                    );
                  }
                }
              },
            ),
          ],
          child: Builder(
            builder: (innerContext) => DsAppResultPage(
              illustration: SvgPicture.asset(
                'assets/images/superapp/topup/ilustration_confimation.svg',
              ),
              title: 'Selesaikan Pembayaran',
              description:
                  'Kamu masih memiliki pembayaran Top Up yang belum diselesaikan!',
              action: TextButton(
                onPressed: () {
                  final qrId = data.qrXenditId;
                  final invoiceId = data.invoiceXenditId;
                  if (invoiceId != null && invoiceId.isNotEmpty) {
                    innerContext
                        .read<ExpireInvoiceBloc>()
                        .add(SubmitExpireInvoiceEvent(invoiceId));
                  } else if (qrId != null && qrId.isNotEmpty) {
                    innerContext
                        .read<ExpireQrcodeBloc>()
                        .add(FetchExpireQrcodeEvent(qrId));
                  }
                },
                child: Text(
                  'Batalkan Pembayaran',
                  style: AppTypography.semiBold14.copyWith(
                    color: AppColors.primaryBase,
                  ),
                ),
              ),
              secondaryAction: DsButton(
                text: 'Bayar Sekarang',
                onPressed: () {
                  final invoiceUrl = data.invoiceXenditUrl;
                  final qrString = data.qrXenditQrstring;

                  if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
                    Navigator.pushReplacement(
                      innerContext,
                      MaterialPageRoute(
                        builder: (_) => WebViewPage(
                          url: invoiceUrl,
                          returnToPaymentMethod: true,
                        ),
                      ),
                    );
                  } else if (qrString != null && qrString.isNotEmpty) {
                    Navigator.pushReplacement(
                      innerContext,
                      MaterialPageRoute(
                        builder: (_) => BarcodeQrisPage(
                          amount: data.qrAmount ?? 0,
                          qrString: qrString,
                          expiresAt: data.qrExpireDate ?? '',
                          qrId: data.qrXenditId ?? '',
                          returnToPaymentMethod: true,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pop(innerContext);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    ).then((_) => _isNavigating = false);
  }

  bool isTopUp() {
    if ((detail?.amountTotal ?? 0) <= (profileData?.kmPoin ?? 0)) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentMethodBloc, PaymentMethodState>(
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
          } else if (state.status == RequestStatus.success &&
              state.checkBillData != null) {
            // Handle CheckActiveBillEvent response
            if (_isNavigating) return;
            _hideLoading();
            _isNavigating = true;
            final checkBillData = state.checkBillData!;
            if (checkBillData.haveActiveBill == true) {
              _navigateToActiveBillFromData(checkBillData);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopupPage()),
              ).then((_) => _isNavigating = false);
            }
          } else if (state.status == RequestStatus.failure &&
              state.operation != 'checkActiveBill') {
            handleFailureState(context, state, state.message);
          } else if (state.status == RequestStatus.empty &&
              state.checkBillData != null) {
            // CheckBillUseCase returns empty when no active bill
            if (_isNavigating) return;
            _hideLoading();
            _isNavigating = true;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TopupPage()),
            ).then((_) => _isNavigating = false);
          } else if (state.status == RequestStatus.loading &&
              state.operation == 'checkActiveBill') {
            _showLoading();
          }
        }),
      ],
      child: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
          builder: (context, state) {
        final isLoadingDetail = state.status == RequestStatus.loading &&
            state.operation == 'getInvoiceDetail';
        if (isLoadingDetail || detail == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFFDF0F1),
            extendBodyBehindAppBar: true,
            appBar: DsAppBar(
              title: 'Metode Pembayaran',
              backgroundColor: Colors.transparent,
              containerLeadingColor: AppColors.alwaysWhite,
              textColor: AppColors.alwaysBlack,
              iconColor: AppColors.alwaysBlack,
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
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
                                  setState(() {
                                    selectedMethod = selected;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              isTopUp()
                                  ? TopUpButton(
                                      onPressed: () {
                                        _checkActiveBillAndNavigate();
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
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 10.0,
                  ),
                  child: CustomButtonIconText(
                    text: 'Bayar Sekarang',
                    onPressed: selectedMethod.isEmpty
                        ? null
                        : () async {
                            handlePaymentButtonLogic();
                          },
                    color: Colors.white,
                    colorText: Colors.white,
                    backGroundColor:
                        selectedMethod.isEmpty ? Colors.grey : primaryColor,
                  )),
            ),
          ],
        );
      }),
    );
  }
}
