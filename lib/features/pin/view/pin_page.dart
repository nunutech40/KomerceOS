import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart'
    as ds;
import 'package:komtim_partner/common/global/mixin/pop_up_pin_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_toast.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';

import '../../../DI/injection.dart';
import '../../../common/enum_status.dart';
import '../../../common/utils/loading/loading_overlay.dart';
import '../../../core/data/shared/payload.dart';
import '../bloc/pin_bloc.dart';

enum PinPageType { setPin, confirmPin, verifyPin, updatePin }

extension PinPageTypeParsing on String {
  PinPageType toPinPageType() {
    switch (this) {
      case 'setPin':
        return PinPageType.setPin;
      case 'confirmPin':
        return PinPageType.confirmPin;
      case 'verifyPin':
        return PinPageType.verifyPin;
      case 'updatePin':
        return PinPageType.updatePin;
      default:
        throw ArgumentError('Unknown PinPageType: $this');
    }
  }
}

class WithdrawalData {
  num nominal; // can hold both int and double values
  int bankAccountId;
  String noRekening;

  WithdrawalData(
      {required this.nominal,
      required this.bankAccountId,
      required this.noRekening});

  void setNominal(num newNominal) {
    nominal = newNominal;
  }

  void setBankAccountId(int newBankAccountId) {
    bankAccountId = newBankAccountId;
  }
}

class PinPage extends StatefulWidget {
  final PinPageType pinType;
  final String? firstPin;
  final String? doJobfor;
  final String? invoiceId;
  final String? statusA;
  final String? xenditUrl;
  const PinPage({
    Key? key,
    required this.pinType,
    this.firstPin,
    this.doJobfor,
    this.invoiceId,
    this.statusA,
    this.xenditUrl,
  }) : super(key: key);

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> with PopUpPin {
  String? firstPin;
  String? appBarTitle;
  String? title;
  String? subtitle;
  String? errorMessage;
  final storage = const FlutterSecureStorage();
  final sharedDataService = locator<SharedDataService>();
  WithdrawalData? withdrawalData;
  String? email;

  // Flow lupa PIN dari Payment Method idealnya membawa doJobFor=updateNewPin.
  // Sebagai fallback, gunakan jejak token OTP + context payment agar tidak
  // salah fallback ke redirect Home.
  bool _isForgotPinPaymentFlow(PinState state) {
    if (widget.doJobfor == 'updateNewPin') return true;

    final hasOtpToken = state.otpToken != null && state.otpToken!.isNotEmpty;
    final hasPaymentContext = (widget.invoiceId?.isNotEmpty ?? false) ||
        (widget.xenditUrl?.isNotEmpty ?? false);

    return hasOtpToken && hasPaymentContext;
  }

  String _safeDecodeQueryValue(String value) {
    if (value.isEmpty) return value;
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }

  void _goToPaymentMethod() {
    final queryParams = <String, String>{};

    if (widget.invoiceId != null && widget.invoiceId!.isNotEmpty) {
      queryParams['id'] = widget.invoiceId!;
    }

    if (widget.xenditUrl != null && widget.xenditUrl!.isNotEmpty) {
      queryParams['xenditUrl'] = _safeDecodeQueryValue(widget.xenditUrl!);
    }

    if (queryParams.isEmpty) {
      AppRouter.router.go(PAGES.paymentmethod.screenPath);
      return;
    }

    final query = Uri(queryParameters: queryParams).query;
    AppRouter.router.go('${PAGES.paymentmethod.screenPath}?$query');
  }

  Future<void> _showForgotPinPaymentSuccessModal() async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return PopScope(
          canPop: false,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + MediaQuery.of(sheetContext).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/superapp/auth/success_reset_password.svg',
                  height: 250,
                  width: 250,
                ),
                const SizedBox(height: 20),
                const Text(
                  Strings.label_pin_success_title,
                  style: AppTypography.semiBold20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Jangan berikan PIN kamu ke siapapun',
                  style: AppTypography.regular14grey73,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _goToPaymentMethod();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai',
                      style: AppTypography.semiBold14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setupData();
    setupLayout();
    // Ambil email dari local profile untuk dipakai di "Lupa Pin?"
    context.read<PinBloc>().add(GetProfileLocalEvent());
  }

  void setupData() {
    withdrawalData = sharedDataService.data;
  }

  void setupLayout() {
    switch (widget.pinType) {
      case PinPageType.setPin:
        appBarTitle = Strings.label_create_pin;
        title = Strings.label_input_6_digit_pin;
        break;
      case PinPageType.updatePin:
        if (widget.doJobfor == 'updateNewPin') {
          appBarTitle = Strings.label_change_pin;
          title = Strings.label_masukan_ulangi_pin_baru;
          subtitle = Strings.label_masukan_ulangi_pin_baru_desc;
        } else {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_new_pin;
          subtitle = null;
        }
        break;
      case PinPageType.confirmPin:
        if (widget.doJobfor == 'updatePin') {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_same_pin;
          subtitle = null;
        } else if (widget.doJobfor == 'updateNewPin') {
          appBarTitle = Strings.label_change_pin;
          title = Strings.label_reinput_new_pin;
          subtitle = Strings.label_reinput_new_pin_desc;
        } else {
          appBarTitle = Strings.label_create_pin;
          title = Strings.label_input_same_pin;
          subtitle = null;
        }

        break;
      case PinPageType.verifyPin:
        if (widget.doJobfor == 'changePin') {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_6_digit_pin;
          subtitle = null;
        } else {
          appBarTitle = Strings.label_verif_pin;
          title = Strings.label_input_6_digit_pin;
          subtitle = null;
        }
        break;
    }
  }

  void handlePinCompleted(String pin) async {
    final pinBloc = context.read<PinBloc>();
    switch (widget.pinType) {
      case PinPageType.setPin:
        await storage.write(key: 'tempFirstPin', value: pin);
        AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
          'pinType': 'confirmPin',
          'firstPin': pin,
          'doJobFor': 'savePin'
        });
        break;
      case PinPageType.updatePin:
        await storage.write(key: 'tempFirstPin', value: pin);
        if (widget.doJobfor == 'updateNewPin') {
          AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
            'pinType': 'confirmPin',
            'firstPin': pin,
            'doJobFor': 'updateNewPin',
            'invoiceId': widget.invoiceId,
            'xenditUrl': widget.xenditUrl,
          });
        } else {
          AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
            'pinType': 'confirmPin',
            'firstPin': pin,
            'doJobFor': 'updatePin',
            'invoiceId': widget.invoiceId,
            'xenditUrl': widget.xenditUrl,
          });
        }
        break;
      case PinPageType.confirmPin:
        String? storedFirstPin = await storage.read(key: 'tempFirstPin');
        if (storedFirstPin == pin) {
          if (widget.doJobfor == "savePin") {
            pinBloc.add(SavePinFullEvent(pin: pin));
          } else if (widget.doJobfor == "updatePin") {
            pinBloc.add(UpdatePinFullEvent(pin: pin));
          } else if (widget.doJobfor == 'updateNewPin') {
            pinBloc.add(UpdatePinFullEvent(pin: pin));
          }
          await storage.delete(
              key: 'tempFirstPin'); // clear the temp pin after use
        } else {
          // display error message (PIN konfirmasi tidak sama)
          setState(() {
            errorMessage = Strings.label_inputed_pin_incorrect;
          });
        }
        break;
      case PinPageType.verifyPin:
        pinBloc.add(VerifyPinFullEvent(pin: pin));
        break;
    }
  }

  void doWithdrawal(BuildContext localContext, state) {
    if (withdrawalData == null) {
      throw Exception("Withdrawal data cannot be null.");
    }

    final pinBloc = context.read<PinBloc>();
    pinBloc.add(DoWithdrawalEvent(
      nominal: withdrawalData!.nominal.toInt(),
      bankAccountId: withdrawalData!.bankAccountId,
    ));
  }

  void doPaymentKompay(BuildContext, State, id) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(DoPaymentKompayEvent(id: id));
  }

  void _deleteTime(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(DeletetTimeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        // Abaikan state dari route yang tidak aktif agar halaman PIN lama
        // di stack tidak ikut mengeksekusi redirect.
        final route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) return;

        if (state.status == RequestStatus.success) {
          switch (state.operation) {
            case 'savePin':
              AppRouter.router.go(PAGES.main.screenPath);
              showToast(context, 'PIN Berhasil Dibuat');
              break;

            case 'updatePin':
              // Hanya halaman konfirmasi PIN yang boleh menangani hasil update PIN.
              if (widget.pinType != PinPageType.confirmPin) break;

              _deleteTime(context, state);
              if (_isForgotPinPaymentFlow(state)) {
                _showForgotPinPaymentSuccessModal();
              } else {
                showToast(context, 'PIN Berhasil Diubah');
                AppRouter.router.go(PAGES.main.screenPath);
              }
              break;

            case 'verifyPin':
              if (state.pinData?.isValid ?? false) {
                if (widget.doJobfor == "withdrawal") {
                  if (withdrawalData != null) {
                    doWithdrawal(context, state);
                  }
                } else if (widget.doJobfor == "changePin") {
                  AppRouter.router.push(PAGES.pinPage.screenPath,
                      extra: {'pinType': 'updatePin'});
                } else if (widget.doJobfor == "payment") {
                  doPaymentKompay(context, state, widget.invoiceId);
                }
              } else {
                setState(() {
                  errorMessage = Strings.label_inputed_pin_incorrect;
                });
              }
              break;

            case 'withdrawalReq':
              AppRouter.router
                  .push('${PAGES.successPage.screenPath}?doJobFor=withdrawal');
              break;

            case 'doPaymentKompay':
              AppRouter.router.push(
                  '${PAGES.successPayment.screenPath}?invoiceId=${widget.invoiceId}&status=${widget.statusA}');
              break;
          }
        } else if (state.status == RequestStatus.failure) {
          // Handle failure state
          // For example, show a snackbar with error message
          if (state.operation == 'updatePin') {
            // Jangan lempar ke home saat gagal — biarkan user tetap di halaman ini.
            showToast(context, 'PIN Gagal Diubah');
          } else if (state.operation == 'savePin') {
            // Jangan lempar ke home saat gagal — biarkan user tetap di halaman ini.
            showToast(context, 'PIN Gagal Dibuat');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title:
                    Text(appBarTitle ?? '', style: AppTypography.interBold16),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 200.0,
                        child: Column(
                          children: [
                            Text(
                              title ?? '',
                              style: AppTypography.semiBold16,
                              textAlign: TextAlign.center,
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 8.0),
                              Text(
                                subtitle!,
                                style: AppTypography.regular14grey73,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35.0),
                    Center(
                      child: ds.DsOtpField(
                        onCompleted: handlePinCompleted,
                        onChanged: (currentPin) {
                          // Validasi konfirmasi PIN: tampilkan error jika
                          // 6 digit sudah terisi tapi tidak sama dengan PIN pertama
                          if (widget.pinType == PinPageType.confirmPin &&
                              currentPin.length == 6) {
                            setState(() {
                              errorMessage = (currentPin != widget.firstPin)
                                  ? Strings.label_inputed_pin_incorrect
                                  : '';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                        child: Text(
                      errorMessage ?? '',
                      style:
                          AppTypography.regular12.copyWith(color: errorColor),
                    )),
                    Container(
                      margin: const EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Route ke halaman pemilih metode OTP (lupa PIN)
                            final emailToUse =
                                email ?? state.profileData?.email ?? '';
                            final invoiceId = widget.invoiceId ?? '';
                            final xenditUrl =
                                Uri.encodeComponent(widget.xenditUrl ?? '');
                            AppRouter.router.push(
                                '${PAGES.chooseOtpMethod.screenPath}?email=$emailToUse&invoiceId=$invoiceId&xenditUrl=$xenditUrl');
                          },
                          child: Text(
                            (widget.doJobfor == 'changePin' ||
                                    widget.doJobfor == 'payment')
                                ? 'Lupa Pin?'
                                : '',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.status == RequestStatus.loading) const LoadingOverlay(),
          ],
        );
      },
    );
  }
}
