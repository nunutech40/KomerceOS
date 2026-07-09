import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/widgets/custom_text_field.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/kompay/bloc/topup_bloc.dart';
import 'package:komtim_partner/DI/injection.dart' as di;
import 'package:komtim_partner/features/kompay/view/bankpayment_pages.dart';
import 'package:komtim_partner/features/kompay/widget/custom_bottom_sheet.dart';
import 'package:komtim_partner/features/kompay/widget/custom_radiolist_tile.dart';

import 'dart:math' as math;

class TopupPages extends StatefulWidget {
  const TopupPages({super.key});

  @override
  State<TopupPages> createState() => _TopupPagesState();
}

class _TopupPagesState extends State<TopupPages> {
  TextEditingController currencyController = TextEditingController();
  int _cleanedValue = 0;
  int? _selectedIndex = -1;
  String? typeTransfer;
  String? errorMessage;
  int? nominal;
  bool selectedNominalCard = false;
  bool? radioButtonActiveBank = false;
  bool? radioButtonActiveQRIS = false;

  List<Map<String, dynamic>> listDataNominal = [
    {"nominal": "10000", "nominalText": "10rb"},
    {"nominal": "50000", "nominalText": "50rb"},
    {"nominal": "100000", "nominalText": "100rb"},
    {"nominal": "500000", "nominalText": "500rb"},
  ];

  @override
  void initState() {
    _setupCurrencyControllerListener();
    super.initState();
  }

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }

  widgetNominal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            Strings.label_nominal,
            style: AppTypography.semiBold16.copyWith(color: Colors.black),
          ),
        ),
        CustomTextField(
          label: '',
          hint: 'Minimal Rp10.000',
          onlyNumbers: true,
          controller: currencyController,
          errorText: errorMessage,
        )
      ],
    );
  }

  widgetNominalCard() {
    return Container(
        // height: 70,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 35),
        child: GridView.builder(
          itemCount: listDataNominal.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _selectedIndex = index;
                currencyController.text = listDataNominal[index]['nominal'];
                selectedNominalCard = true;
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:
                        selectedNominalCard == true && _selectedIndex == index
                            ? lighPrimaryColor
                            : Colors.white,
                    border: Border.all(
                        color: selectedNominalCard == true &&
                                _selectedIndex == index
                            ? primaryColor
                            : e2Gray)),
                child: Center(
                    child: Text(
                  listDataNominal[index]['nominalText'],
                  style: AppTypography.medium12,
                )),
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: (7 / 3),
              crossAxisCount: 4,
              crossAxisSpacing: 10),
        ));
  }

  widgetRadioCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            Strings.label_payment_method,
            style: AppTypography.semiBold14.copyWith(color: Colors.black),
          ),
        ),
        CustomRadioListTile(
          images: "assets/images/bank.svg",
          title: Strings.label_bank_transfer,
          text: Strings.dialog_attention_nominal_topup,
          value: "Bank",
          groupValue: typeTransfer,
          onChanged: radioButtonActiveBank == false
              ? null
              : (value) {
                  typeTransfer = value;
                  setState(() {});
                },
        ),
        CustomRadioListTile(
            images: "assets/images/qris.svg",
            title: Strings.label_use_qris,
            text: Strings.dialog_no_admin_fees_charged,
            value: "QRIS",
            groupValue: typeTransfer,
            onChanged: radioButtonActiveQRIS == false
                ? null
                : (value) {
                    typeTransfer = value;
                    setState(() {});
                  })
      ],
    );
  }

  void showModalPayment(
    BuildContext context,
    String nominal,
    String? jenistf,
  ) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          //View
          return BlocProvider(
              create: (context) => di.locator<TopUpBloc>(),
              child: CustomBottomSheet(nominal: nominal, jenistf: jenistf));
        });
  }

  void _setupCurrencyControllerListener() {
    currencyController.addListener(() {
      selectedNominalCard = false;
      final inputValue = currencyController.text;

      final cleanedValue = _cleanInputValue(inputValue);
      _cleanedValue = cleanedValue;

      if (_cleanedValue < 10000) {
        errorMessage = Strings.label_nom_min_topup;
        radioButtonActiveBank = false;
        radioButtonActiveQRIS = false;
        typeTransfer = null;
        setState(() {});
      } else {
        errorMessage = null; // clear the error message
        nominal = _cleanedValue;
        if (_cleanedValue <= 500000) {
          radioButtonActiveBank = true;
          radioButtonActiveQRIS = true;
        } else if (_cleanedValue >= 500001) {
          radioButtonActiveBank = true;
          radioButtonActiveQRIS = false;
          if (typeTransfer == "QRIS") {
            typeTransfer = null;
          }
        }
        setState(() {});
      }

      final validatedValue = _validateMaxValue(cleanedValue);
      final formattedValue = _formatValue(validatedValue);
      _updateControllerValue(formattedValue);
      // _updateButtonActivationStatus(validatedValue);
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
    if (formattedValue != currencyController.text) {
      currencyController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  currencyFormat(double nominal) {
    final currencyFormatter = NumberFormat('#,##0', 'ID');
    String hasil = currencyFormatter.format(nominal);
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(Strings.label_topup,
              style: AppTypography.interSemiBold16),
          leading: IconButton(
            icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
            onPressed: () {
              AppRouter.router.pop();
            },
          ),
        ),
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widgetNominal(),
                  widgetNominalCard(),
                  widgetRadioCard(),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: BottomElevationContainer(
                status: nominal != null && typeTransfer != null ? true : false,
                elevationHeight: 95,
                onTap: () {
                  showModalPayment(context, nominal.toString(), typeTransfer);
                },
                content: const Center(
                  child: Text(Strings.label_continue_the_payment,
                      style: AppTypography.medium14White),
                ),
              ))
        ]));
  }
}
