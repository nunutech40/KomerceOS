import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  const PinPage({
    Key? key,
    required this.pinType,
    this.firstPin,
    this.doJobfor,
    this.invoiceId,
    this.statusA,
  }) : super(key: key);

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> with PopUpPin {
  String? firstPin;
  String? appBarTitle;
  String? title;
  String? errorMessage;
  final storage = const FlutterSecureStorage();
  final sharedDataService = locator<SharedDataService>();
  WithdrawalData? withdrawalData;
  String? email;

  @override
  void initState() {
    super.initState();
    setupData();
    setupLayout();
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
          title = Strings.label_input_new_pin;
        } else {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_new_pin;
        }
        break;
      case PinPageType.confirmPin:
        if (widget.doJobfor == 'updatePin') {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_same_pin;
        } else if (widget.doJobfor == 'updateNewPin') {
          appBarTitle = Strings.label_change_pin;
          title = Strings.label_input_same_pin;
        } else {
          appBarTitle = Strings.label_create_pin;
          title = Strings.label_input_same_pin;
        }

        break;
      case PinPageType.verifyPin:
        if (widget.doJobfor == 'changePin') {
          appBarTitle = Strings.label_set_pin;
          title = Strings.label_input_6_digit_pin;
        } else {
          appBarTitle = Strings.label_verif_pin;
          title = Strings.label_input_6_digit_pin;
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
            'doJobFor': 'updateNewPin'
          });
        } else {
          AppRouter.router.push(PAGES.pinPage.screenPath, extra: {
            'pinType': 'confirmPin',
            'firstPin': pin,
            'doJobFor': 'updatePin'
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

  void _getProfileEmail(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(GetProfileEmail());
  }

  void _forgetPin(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(ForgetPinEvent());
  }

  void _saveTime(BuildContext localContext, state, String time) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(SaveTimeEvent(time: time));
  }

  void _getTime(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(GetTimeEvent());
  }

  void _deleteTime(BuildContext localContext, state) {
    final pinBloc = context.read<PinBloc>();
    pinBloc.add(DeletetTimeEvent());
  }

  bool isTimeLessThan(String timeString) {
    DateTime currentTime = DateTime.now();
    DateTime targetTime = DateTime.parse(timeString);

    return targetTime.isBefore(currentTime);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        // Handle the various state changes here
        if (state.status == RequestStatus.success) {
          switch (state.operation) {
            case 'getTime':
              if (state.expiredAt?.expiredAt == '') {
                _getProfileEmail(context, state);
              } else {
                bool result = isTimeLessThan(state.expiredAt?.expiredAt ?? '');
                if (result) {
                  _getProfileEmail(context, state);
                } else {
                  AppRouter.router.push(
                      '${PAGES.pinOtpVerification.screenPath}?email=$email&time=${state.expiredAt?.expiredAt}');
                }
              }
            case 'forgetPin':
              _saveTime(context, state, state.expiredAt?.expiredAt ?? '');
              AppRouter.router.push(
                  '${PAGES.pinOtpVerification.screenPath}?email=$email&time=${state.expiredAt?.expiredAt}');
            case 'getProfile':
              email = state.profileData?.email;
              _forgetPin(context, state);
            case 'savePin':
              AppRouter.router.go(PAGES.main.screenPath);
              showToast(context, 'PIN Berhasil Dibuat');
            case 'updatePin':
              _deleteTime(context, state);
              AppRouter.router.go(PAGES.main.screenPath);
              showToast(context, 'PIN Berhasil Diubah');
            case 'verifyPin':
              if (state.pinData?.isValid ?? false) {
                if (widget.doJobfor == "withdrawal") {
                  if (withdrawalData != null) {
                    doWithdrawal(context, state);
                  } else {
                    // Handle the error, either by throwing, logging, or showing a user-friendly message
                    // Handle the error, either by throwing, logging, or showing a user-friendly message
                    // print('Error: widget.withdrawalData is null.');
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
            case 'withdrawalReq':
              AppRouter.router
                  .push('${PAGES.successPage.screenPath}?doJobFor=withdrawal');

            case 'doPaymentKompay':
              AppRouter.router.push(
                  '${PAGES.successPayment.screenPath}?invoiceId=${widget.invoiceId}&status=${widget.statusA}');

              break;
            // Add other cases if needed based on different operations
          }
        } else if (state.status == RequestStatus.failure) {
          // Handle failure state
          // For example, show a snackbar with error message
          if (state.operation == 'updatePin') {
            AppRouter.router.go(PAGES.main.screenPath);
            showToast(context, 'PIN Gagal Diubah');
          } else if (state.operation == 'savePin') {
            AppRouter.router.go(PAGES.main.screenPath);
            showToast(context, 'PIN Gagal Dibuat');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Unknown Error')),
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
                        child: Text(
                          title ?? '',
                          style: AppTypography.medium14,
                          textAlign: TextAlign.center,
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
                            //uncomment this
                            _getTime(context, state);
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
