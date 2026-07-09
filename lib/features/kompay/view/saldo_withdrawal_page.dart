import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/mixin/pop_up_pin_page.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button_primary.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';
import 'package:komtim_partner/core/data/models/profile_response.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:komtim_partner/features/invoice/widget/bottom_sheet_balance.dart';
import 'package:komtim_partner/features/kompay/bloc/saldo_withdrawal_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../DI/injection.dart';
import '../../../common/enum_status.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/widgets/custom_button.dart';
import '../../../common/global/widgets/custom_drop_down.dart';
import '../../../common/global/widgets/custom_outline_button.dart';
import '../../../common/global/widgets/custom_text_field.dart';
import '../../../common/styles.dart';
import '../../../common/utils/currency_format.dart';
import '../../../common/utils/loading/loading_overlay.dart';
import '../../../core/data/shared/payload.dart';
import '../../../core/domain/entities/bank_accounts_model.dart';
import '../../pin/view/pin_page.dart';
import '../widget/saldo_widget.dart';

class SaldoWithdrawalPage extends StatefulWidget {
  final int saldoKompay;
  const SaldoWithdrawalPage({Key? key, required this.saldoKompay})
      : super(key: key);

  @override
  State<SaldoWithdrawalPage> createState() => _SaldoWithdrawalPageState();
}

class _SaldoWithdrawalPageState extends State<SaldoWithdrawalPage>
    with ErrorHandlingMixin, PopUpPin {
  final TextEditingController _currencyController = TextEditingController();
  bool _isActive = false;
  String? _errorText;
  bool pinSetted = false;
  String? selectedBankAccount;
  int? _cleanedValue;
  int? _selectedBankAccountId;
  final storage = const FlutterSecureStorage();
  var _bloc;

  @override
  final pref = di.locator<SharedPref>();
  ProfileResponse? profile;
  IdealBalanceModel? idealBalanceData;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    loadData();
  }

  void _initializeBloc() {
    _bloc = context.read<SaldoWithdrawalBloc>();
  }

  void loadData() async {
    profile = await pref.getProfileResponse();
    await _bloc.add(IdealBalanceEvent(partnerId: profile?.partnerId ?? 0));
    selectedBankAccount = Strings.label_choose_your_rek;
    _setupCurrencyControllerListener();
    await _bloc.add(const BankDataLoad());
  }

  void refreshData() async {
    await _bloc.add(const RefreshDataEvent());

    // refresh data property
  }

  void _setupCurrencyControllerListener() {
    // Tambahkan listener ke _currencyController untuk memonitor perubahan nilai yang dimasukkan oleh pengguna
    _currencyController.addListener(() {
      final inputValue = _currencyController.text;

      // Bersihkan dan validasi nilai input
      final cleanedValue = _cleanInputValue(inputValue);
      _cleanedValue = cleanedValue;
      final validatedValue = _validateMaxValue(cleanedValue);

      // Ubah format nilai yang telah divalidasi
      final formattedValue = _formatValue(validatedValue);

      // Perbarui nilai di _currencyController dengan format yang benar
      _updateControllerValue(formattedValue);

      // Periksa apakah nilai yang dimasukkan valid untuk mengaktifkan tombol
      _updateButtonActivationStatus(validatedValue);
      CustomDropDown.myWidgetKey.currentState?.closeOverlay();
    });
  }

  int _cleanInputValue(String inputValue) {
    // Hilangkan semua titik dari inputValue dan coba ubah menjadi bilangan bulat.
    // Jika gagal, kembalikan 0.
    return int.tryParse(inputValue.replaceAll(".", "")) ?? 0;
  }

  int _validateMaxValue(int value) {
    // Pastikan nilai yang diberikan tidak melebihi nilai maksimum yang diizinkan
    const maxAllowedValue = 5000000;
    return math.min(value, maxAllowedValue);
  }

  String _formatValue(int value) {
    // Ubah format nilai menjadi format mata uang tanpa simbol mata uang
    return CurrencyFormat.convertWithoutSymbol(value, 0);
  }

  void _updateControllerValue(String formattedValue) {
    // Jika nilai yang diformat berbeda dari nilai saat ini di _currencyController,
    // perbarui _currencyController dengan nilai yang benar
    if (formattedValue != _currencyController.text) {
      _currencyController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  void _updateButtonActivationStatus(int value) {
    if (value > widget.saldoKompay ||
        value < 10000 ||
        selectedBankAccount == Strings.label_choose_your_rek) {
      // Set the appropriate error message
      if (value > widget.saldoKompay) {
        _errorText = Strings.label_not_enough_saldo;
      } else if (value < 10000) {
        _errorText = Strings.label_min_withdrawal;
      } else {
        _errorText =
            null; // Consider setting an error for the bank account if necessary
      }

      setState(() {
        _isActive = false;
      });
      return;
    }

    setState(() {
      _isActive = true;
      _errorText = null; // clear error if input is valid
    });
  }

  void showCustomBottomSheet({
    required BuildContext context,
    required int type,
  }) {
    try {
      if (idealBalanceData == null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BottomSheetBalance(
            type: type,
          ),
        );
      }
      final DashboardBalanceDataModel dashboardData =
          idealBalanceData!.toDashboardData();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BottomSheetBalance(type: type, data: dashboardData),
      );
    } catch (e) {
      // Handle the exception, e.g., log it or show an error message
      // debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  Map<int, String> generateBankAccountsMap(
      List<BankAccountsDataModel> bankList) {
    Map<int, String> bankMap = {0: Strings.label_choose_your_rek};
    for (var bank in bankList) {
      bankMap[bank.bankAccountsId ?? 0] =
          '${bank.bankCode} - ${bank.bankOwnerNumber}';
    }
    return bankMap;
  }

  Map<int, String> bankAccountsMap = {0: Strings.label_choose_your_rek};

  @override
  Widget build(BuildContext context) {
    void showPopUp() {
      AppRouter.router
          .push(PAGES.pinPage.screenPath, extra: {'pinType': 'setPin'});
      Navigator.of(context).pop();
    }

    return BlocConsumer<SaldoWithdrawalBloc, SaldoWitdrawalState>(
      listener: (context, state) async {
        if (state.status == RequestStatus.success &&
            state.operation == 'checkPinExist') {
          if (state.pinData?.isExist ?? false) {
            if (_cleanedValue == null || _selectedBankAccountId == null) {
              return; // Exit the function early if the values aren't set
            }

            var dataPayload = WithdrawalData(
                nominal: _cleanedValue!,
                bankAccountId: _selectedBankAccountId!,
                noRekening: selectedBankAccount!);

            final sharedDataService = locator<SharedDataService>();
            sharedDataService.data = dataPayload;

            AppRouter.router.push(PAGES.pinPage.screenPath,
                extra: {'pinType': 'verifyPin', 'doJobFor': 'withdrawal'});
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
      },
      builder: (context, state) {
        if (state.status == RequestStatus.success &&
            state.operation == 'idealBalanceCheck') {
          idealBalanceData = state.idealBalance;
        }
        if (state.status == RequestStatus.success &&
            state.operation == 'getBankList') {
          bankAccountsMap.clear();
          bankAccountsMap.addAll(generateBankAccountsMap(state.bankList!));
        } else if (state.status == RequestStatus.failure) {
          Future.delayed(Duration.zero, () {
            if (!context.mounted) return;

            handleFailureState(context, state, state.message);
          });
        }

        List<String> bankAccountValues = bankAccountsMap.values.toList();

        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(Strings.label_saldo_withdrawal,
                    style: AppTypography.interSemiBold16),
                leading: IconButton(
                  icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
                  onPressed: () {
                    AppRouter.router.pop();
                  },
                ),
              ),
              bottomNavigationBar: Container(
                padding: EdgeInsets.only(
                    bottom: math.max(
                        0, MediaQuery.of(context).viewInsets.bottom - 10)),
                margin: const EdgeInsets.only(bottom: 24.0),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: CustomOutlineButton(
                            text: Strings.label_cancel,
                            onPressed: () {
                              AppRouter.router.pop();
                            },
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Expanded(
                          child: CustomButton(
                            text: Strings.label_contie,
                            onPressed: () {
                              // debugPrint(
                              //     'Ideal Balance: ${(idealBalanceData?.idealBalance ?? 0)}');
                              // debugPrint(
                              //     'Ideal Balance + penarikan: ${(_cleanedValue ?? 0) + (idealBalanceData?.idealBalance ?? 0)}');
                              if ((_cleanedValue ?? 0) +
                                      (idealBalanceData?.idealBalance ?? 0) >
                                  widget.saldoKompay) {
                                showCustomBottomSheet(
                                    context: context, type: 1);
                              } else {
                                final bloc =
                                    context.read<SaldoWithdrawalBloc>();
                                bloc.add(const NextPressedButtonEvent());
                              }
                            },
                            isActive: _isActive,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30.0,
                    ),
                    SaldoWidget(
                        text1: Strings.label_saldo,
                        text2:
                            CurrencyFormat.convertToIdr(widget.saldoKompay, 0)),
                    const SizedBox(
                      height: 24.0,
                    ),
                    const Text(
                      Strings.label_nominal,
                      style: AppTypography.regular12,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    CustomTextField(
                      label: '',
                      hint: 'contoh:500.000',
                      onlyNumbers: true,
                      controller: _currencyController,
                      errorText: _errorText,
                      onTap: () {
                        CustomDropDown.myWidgetKey.currentState?.closeOverlay();
                      },
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    const Text(
                      Strings.label_destination_rek,
                      style: AppTypography.regular12,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    bankAccountsMap.length > 1
                        ? CustomDropDown(
                            key: CustomDropDown.myWidgetKey,
                            label: '',
                            items: bankAccountValues,
                            selectedItem:
                                selectedBankAccount ?? bankAccountValues[0],
                            isLoading: state.status == RequestStatus.loading &&
                                state.operation == 'getBankList',
                            onChanged: (String newValue) {
                              selectedBankAccount = newValue;

                              var selectedEntry = bankAccountsMap.entries
                                  .firstWhere(
                                      (entry) => entry.value == newValue,
                                      orElse: () => const MapEntry(-1,
                                          "Not Found") // Using -1 as a default ID to indicate not found.
                                      );

                              if (selectedEntry.key != -1) {
                                _selectedBankAccountId = selectedEntry.key;
                              }
                              _updateButtonActivationStatus(
                                  _cleanInputValue(_currencyController.text));
                              // ... [rest of the onChanged logic remains unchanged]
                            },
                          )
                        : Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.024,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.0040),
                                decoration: BoxDecoration(
                                  color: lightWarningColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.054,
                                      width: MediaQuery.of(context).size.width *
                                          0.073,
                                      child: SvgPicture.asset(
                                          "assets/images/info-circle.svg"),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.024,
                                    ),
                                    const Expanded(
                                      child: Text(
                                        Strings.label_information_bank_zero,
                                        style:
                                            AppTypography.regular12WarningDark,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.0098,
                              ),
                              CustomeOutlineButtonPrimary(
                                  text: Strings.label_call_admin_wa,
                                  onPressed: () {
                                    sendWhatapps();
                                  },
                                  icon: "assets/images/ic_whatsapp.svg"),
                            ],
                          )
                  ],
                ),
              ),
            ),
            if (state.status == RequestStatus.loading &&
                state.operation == 'checkPinExist')
              const LoadingOverlay(),
          ],
        );
      },
    );
  }

  void sendWhatapps() async {
    var whatsappUrl = Uri.parse("whatsapp://send?phone=+6283865360055"
        "&text=Halo Komtim, bisa tolong bantu input nomer rekening berikut? \nNama Partner: \nNama Pemilik Rekening: \nBank: \nNomer Rekening: ");
    try {
      await launchUrl(whatsappUrl);
    } catch (e) {
      //To handle error and display error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Tidak bisa membuka whatapp atau whatapp belum terinstall"),
          backgroundColor: errorColor));
    }
  }
}

extension DashboardToIdeal on DashboardBalanceDataModel {
  IdealBalanceModel toIdealModel() => IdealBalanceModel(
        idealBalance: idealBalance,
        shippingReturPotential: ongkirReturPotential,
        inComeOrderPotential: incomeOrderPotential,
        shippingReturOnFinished: ongkirReturOnFinished,
        shippingRiskBecomeRetur: ongkirRiskBecomeRetur,
        onWithdrawl: onWithdrawl,
      );
}

extension IdealToDashboard on IdealBalanceModel {
  DashboardBalanceDataModel toDashboardData() => DashboardBalanceDataModel(
        idealBalance: idealBalance ?? 0,
        ongkirReturPotential: shippingReturPotential ?? 0,
        incomeOrderPotential: inComeOrderPotential ?? 0,
        ongkirReturOnFinished: shippingReturOnFinished ?? 0,
        ongkirRiskBecomeRetur: shippingRiskBecomeRetur ?? 0,
        onWithdrawl: onWithdrawl ?? 0,
      );
}
