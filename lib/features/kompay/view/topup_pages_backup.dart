// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:komtim_partner/common/enum_status.dart';
// import 'package:komtim_partner/common/global/router/app_router.dart';
// import 'package:komtim_partner/common/global/router/router_utils.dart';
// import 'package:komtim_partner/common/global/widgets/custom_text_field.dart';
// import 'package:komtim_partner/common/string.dart';
// import 'package:komtim_partner/common/styles.dart';
// import 'package:komtim_partner/common/utils/currency_format.dart';
// import 'package:komtim_partner/features/kompay/bloc/topup_bloc.dart';
// import 'package:komtim_partner/features/kompay/bloc/topup_event.dart';
// import 'package:komtim_partner/features/kompay/bloc/topup_state.dart';
// import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
// import 'dart:math' as math;

// import 'package:komtim_partner/features/ratetalent/view/web_view_page.dart';

// class TopupPages extends StatefulWidget {
//   const TopupPages({super.key});

//   @override
//   State<TopupPages> createState() => _TopupPagesState();
// }

// class _TopupPagesState extends State<TopupPages> with ErrorHandlingMixin {
//   TextEditingController currencyController = TextEditingController();
//   int _cleanedValue = 0;
//   ValueNotifier<String?> _errorMessageNotifier = ValueNotifier<String?>(null);
//   ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
//   String selectedValue = '';

//   var _bloc;

//   @override
//   void initState() {
//     _setupCurrencyControllerListener();
//     loadData();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     currencyController.dispose();
//     super.dispose();
//   }

//   void loadData() async {
//     _bloc = context.read<TopUpBloc>();
//   }

//   void handleRadioValueChanged(
//       String? nominal, String? value, bool bank, bool qris) {
//     selectedValue = value ?? "";
//     context.read<TopUpBloc>().add(HandleRadioButtonChangedEvent(
//         nominal: nominal ?? "",
//         tfBank: bank,
//         tfQris: qris,
//         jenisTf: value ?? ""));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text(Strings.label_topup, style: AppTypography.interSemiBold16),
//         leading: IconButton(
//           icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
//           onPressed: () {
//             AppRouter.router.pop();
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 NominalWidget(
//                     currencyController: currencyController,
//                     errorMessageNotifier: _errorMessageNotifier),
//                 BoxNominalWidget(),
//                 BlocConsumer<TopUpBloc, TopupState>(listener: (context, state) {
//                   currencyController.text = state.nominal;
//                   if (state.dataTopUpBank?.transactionPaymentUrl != '' &&
//                       state.jenisTf == "Bank") {
//                     if (state.status == RequestStatus.success) {
//                       _isLoadingNotifier.value = false;
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => WebViewPage(
//                               url: state.dataTopUpBank?.transactionPaymentUrl ??
//                                   "")));
//                     } else if (state.status == RequestStatus.failure) {
//                       _isLoadingNotifier.value = false;
//                       handleFailureState(context, state, state.message);
//                     }
//                   } else if (state.dataResponseQris?.transactionCode != '' &&
//                       state.jenisTf == "QRIS") {
//                     if (state.status == RequestStatus.success) {
//                       _isLoadingNotifier.value = false;
//                       AppRouter.router.pushNamed(PAGES.qrispayment.screenName,
//                           queryParameters: {
//                             'transaction_id': [
//                               state.dataResponseQris?.transactionId.toString(),
//                             ],
//                             'accessFrom': ['topup']
//                           });
//                     } else if (state.status == RequestStatus.failure) {
//                       handleFailureState(context, state, state.message);
//                       _isLoadingNotifier.value = false;
//                     }
//                   }
//                 }, builder: (context, state) {
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 40),
//                         child: Text(
//                           Strings.label_payment_method,
//                           style: AppTypography.semiBold14
//                               .copyWith(color: Colors.black),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10),
//                         child: RadioListTile<String>(
//                           contentPadding: EdgeInsets.zero,
//                           activeColor: orangeColor,
//                           dense: true,
//                           visualDensity:
//                               VisualDensity(horizontal: -4, vertical: -4),
//                           title: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   SvgPicture.asset(
//                                     'assets/images/bank.svg',
//                                     fit: BoxFit.cover,
//                                   ),
//                                   SizedBox(
//                                     width: 5,
//                                   ),
//                                   Text(
//                                     Strings.label_bank_transfer,
//                                     style: AppTypography.regular16,
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 Strings.dialog_attention_nominal_topup,
//                                 style: AppTypography.interRegular12,
//                               ),
//                             ],
//                           ),
//                           value: 'Bank',
//                           groupValue: selectedValue,
//                           onChanged: state.tfBank == false
//                               ? null
//                               : (value) {
//                                   handleRadioValueChanged(
//                                     state.nominal,
//                                     value,
//                                     state.tfBank,
//                                     state.tfQris,
//                                   );
//                                 },
//                           controlAffinity: ListTileControlAffinity
//                               .platform, // optional, places the radio button on the trailing side
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10),
//                         child: RadioListTile<String>(
//                           contentPadding: EdgeInsets.zero,
//                           activeColor: orangeColor,
//                           dense: true,
//                           visualDensity:
//                               VisualDensity(horizontal: -4, vertical: -4),
//                           title: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Container(
//                                 width: 55,
//                                 height: 20,
//                                 child: SvgPicture.asset(
//                                   'assets/images/qris.svg',
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 5,
//                               ),
//                               Text(
//                                 Strings.label_use_qris,
//                                 style: AppTypography.regular16,
//                               ),
//                             ],
//                           ),
//                           value: 'QRIS',
//                           groupValue: selectedValue,

//                           onChanged: state.tfQris == false
//                               ? null
//                               : (value) {
//                                   handleRadioValueChanged(
//                                     state.nominal,
//                                     value,
//                                     state.tfBank,
//                                     state.tfQris,
//                                   );
//                                 },
//                           subtitle: Text(
//                             Strings.dialog_no_admin_fees_charged,
//                             style: AppTypography.interRegular12,
//                           ),
//                           controlAffinity: ListTileControlAffinity
//                               .platform, // optional, places the radio button on the trailing side
//                         ),
//                       ),
//                     ],
//                   );
//                 })
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: BlocConsumer<TopUpBloc, TopupState>(
//                 listener: (context, TopupState state) {
//               if (int.parse(state.nominal) >= 10000 &&
//                   int.parse(state.nominal) <= 500000 &&
//                   state.jenisTf != "") {
//                 context
//                     .read<TopUpBloc>()
//                     .add(HandlePaymentEvent(statusPayment: true));
//               } else if (int.parse(state.nominal) > 500000 &&
//                   state.jenisTf == "Bank") {
//                 context
//                     .read<TopUpBloc>()
//                     .add(HandlePaymentEvent(statusPayment: true));
//               } else {
//                 context
//                     .read<TopUpBloc>()
//                     .add(HandlePaymentEvent(statusPayment: false));
//               }
//             }, builder: (context, state) {
//               return BottomElevationContainer(
//                 status: state.statusPayment,
//                 elevationHeight: 95,
//                 onTap: () {
//                   showModalPayment(
//                       context, state.nominal, state.jenisTf, state);
//                 },
//                 content: Center(
//                   child: Text(Strings.label_continue_the_payment,
//                       style: AppTypography.medium14White),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   void showModalPayment(
//       BuildContext context, String nominal, String? jenistf, TopupState state) {
//     showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return ValueListenableBuilder<bool>(
//               valueListenable: _isLoadingNotifier,
//               builder: (context, _isLoading, child) {
//                 return Container(
//                     height: 360,
//                     padding: EdgeInsets.symmetric(horizontal: 30),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 15, bottom: 15),
//                           child: Center(
//                               child: Image.asset("assets/images/retangle.png")),
//                         ),
//                         Center(
//                             child: Text(Strings.label_confirm_payment,
//                                 style: AppTypography.semiBold14)),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 20, bottom: 5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(Strings.label_payment_method_full,
//                                   style: AppTypography.interRegular14),
//                               Text('Transfer $jenistf',
//                                   style: AppTypography.semiBold14)
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5, bottom: 5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(Strings.label_nominal_topup,
//                                   style: AppTypography.interRegular14),
//                               Text('Rp${currencyFormat(double.parse(nominal))}',
//                                   style: AppTypography.semiBold14)
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5, bottom: 5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(Strings.label_service_cost,
//                                   style: AppTypography.interRegular14),
//                               state.jenisTf == "QRIS"
//                                   ? Text(Strings.label_free,
//                                       style: AppTypography.textColorGreen)
//                                   : int.parse(nominal) > 500000 &&
//                                           state.jenisTf == "Bank"
//                                       ? Text(Strings.label_free,
//                                           style: AppTypography.textColorGreen)
//                                       : Text(
//                                           'Rp${currencyFormat(double.parse("1000"))}',
//                                           style: AppTypography.semiBold14)
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5, bottom: 5),
//                           child: Center(
//                               child: Divider(
//                             color: e2Gray,
//                           )),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 5, bottom: 5),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(Strings.label_total_bill,
//                                   style: AppTypography.interRegular14),
//                               state.jenisTf == "QRIS"
//                                   ? Text(
//                                       'Rp${currencyFormat(double.parse(nominal))}',
//                                       style: AppTypography.semiBold14)
//                                   : int.parse(nominal) < 500001 &&
//                                           state.jenisTf == "Bank"
//                                       ? Text(
//                                           'Rp${currencyFormat(double.parse((int.parse(nominal) + 1000).toString()))}',
//                                           style: AppTypography.semiBold14)
//                                       : Text(
//                                           'Rp${currencyFormat(double.parse(nominal))}',
//                                           style: AppTypography.semiBold14)
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             top: 70,
//                           ),
//                           child: Container(
//                             color: Colors
//                                 .white, // Change the background color as needed
//                             child: _isLoadingNotifier.value == false
//                                 ? InkWell(
//                                     onTap: () async {
//                                       if (jenistf == "QRIS") {
//                                         _isLoadingNotifier.value = true;
//                                         _bloc
//                                             .add(TopUpButtonPressedQrisEvent());
//                                       } else {
//                                         _isLoadingNotifier.value = true;
//                                         _bloc.add(TopUpButtonPressedEvent());
//                                       }
//                                     },
//                                     child: Container(
//                                       height: 45,
//                                       decoration: BoxDecoration(
//                                           color: primaryColor,
//                                           borderRadius:
//                                               BorderRadius.circular(10)),
//                                       child: Center(
//                                         child: Text(Strings.label_pay,
//                                             style: AppTypography.medium14White),
//                                       ),
//                                     ))
//                                 : Container(
//                                     color: Colors
//                                         .white, // Change the background color as needed
//                                     child: Container(
//                                         height: 45,
//                                         decoration: BoxDecoration(
//                                             color: onlyGray,
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         child: Center(
//                                           child: Text(Strings.label_pay,
//                                               style:
//                                                   AppTypography.medium14White),
//                                         ))),
//                           ),
//                         )
//                       ],
//                     ));
//               });
//         });
//   }

//   void _setupCurrencyControllerListener() {
//     currencyController.addListener(() {
//       final inputValue = currencyController.text;

//       final cleanedValue = _cleanInputValue(inputValue);
//       _cleanedValue = cleanedValue;

//       if (_cleanedValue < 10000) {
//         _errorMessageNotifier.value = Strings.label_nom_min_topup;
//       } else {
//         _errorMessageNotifier.value = null; // clear the error message
//       }

//       final validatedValue = _validateMaxValue(cleanedValue);
//       final formattedValue = _formatValue(validatedValue);
//       _updateControllerValue(formattedValue);
//       // _updateButtonActivationStatus(validatedValue);
//     });
//   }

//   int _cleanInputValue(String inputValue) {
//     // Hilangkan semua titik dari inputValue dan coba ubah menjadi bilangan bulat.
//     // Jika gagal, kembalikan 0.
//     return int.tryParse(inputValue.replaceAll(".", "")) ?? 0;
//   }

//   int _validateMaxValue(int value) {
//     // Pastikan nilai yang diberikan tidak melebihi nilai maksimum yang diizinkan
//     const maxAllowedValue = 5000000;
//     return math.min(value, maxAllowedValue);
//   }

//   String _formatValue(int value) {
//     // Ubah format nilai menjadi format mata uang tanpa simbol mata uang
//     return CurrencyFormat.convertWithoutSymbol(value, 0);
//   }

//   void _updateControllerValue(String formattedValue) {
//     // Jika nilai yang diformat berbeda dari nilai saat ini di _currencyController,
//     // perbarui _currencyController dengan nilai yang benar
//     if (formattedValue != currencyController.text) {
//       currencyController.value = TextEditingValue(
//         text: formattedValue,
//         selection: TextSelection.collapsed(offset: formattedValue.length),
//       );
//     }
//   }
// }

// currencyFormat(double nominal) {
//   final currencyFormatter = NumberFormat('#,##0', 'ID');
//   String hasil = currencyFormatter.format(nominal);
//   return hasil;
// }

// // void loadData() async {
// //   // Invoke Bloc event after initial frame is rendered
// //   await _bloc.add(const HomePageDidload());
// // }

// List<Map<String, dynamic>> listDataNominal = [
//   {"nominal": 10000, "tfBank": true, "tfQris": true, "nominalText": "10rb"},
//   {"nominal": 50000, "tfBank": true, "tfQris": true, "nominalText": "50rb"},
//   {"nominal": 100000, "tfBank": true, "tfQris": true, "nominalText": "100rb"},
//   {"nominal": 500000, "tfBank": true, "tfQris": true, "nominalText": "500rb"},
// ];

// int? _selectedIndex = -1;

// class BoxNominalWidget extends StatefulWidget {
//   BoxNominalWidget({
//     super.key,
//     this.nominal,
//   });
//   String? nominal;
//   @override
//   State<BoxNominalWidget> createState() => _BoxNominalWidgetState();
// }

// class _BoxNominalWidgetState extends State<BoxNominalWidget> {
//   @override
//   void initState() {
//     _selectedIndex = -1;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<TopUpBloc, TopupState>(builder: (context, state) {
//       return Container(
//           // height: 70,
//           width: MediaQuery.of(context).size.width,
//           padding: const EdgeInsets.only(top: 35),
//           child: GridView.builder(
//             itemCount: listDataNominal.length,
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               return BoxNominal(
//                 onTap: () {
//                   _selectedIndex = index;
//                   context.read<TopUpBloc>().add(NominalChangedEvent(
//                       nominal: listDataNominal[index]['nominal'].toString()));

//                   context.read<TopUpBloc>().add(HandleRadioButtonChangedEvent(
//                       nominal: listDataNominal[index]['nominal'].toString(),
//                       tfBank: listDataNominal[index]['tfBank'],
//                       tfQris: listDataNominal[index]['tfQris'],
//                       jenisTf: state.jenisTf));
//                 },
//                 nominal: listDataNominal[index]['nominalText'],
//                 colorActive: _selectedIndex == index ? true : false,
//               );
//             },
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 childAspectRatio: (7 / 3),
//                 crossAxisCount: 4,
//                 crossAxisSpacing: 10),
//           ));
//     });
//   }
// }

// // ignore: must_be_immutable
// class BoxNominal extends StatelessWidget {
//   String? nominal;
//   VoidCallback? onTap;
//   bool colorActive;
//   // bool dividerUse;
//   BoxNominal({
//     super.key,
//     this.nominal,
//     this.onTap,
//     required this.colorActive,
//     // required this.dividerUse
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 6),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(5),
//             color: colorActive == true ? lighPrimaryColor : Colors.white,
//             border: Border.all(
//                 color: colorActive == true ? primaryColor : Colors.black)),
//         child: Center(
//             child: Text(
//           nominal ?? "",
//           style: AppTypography.medium12,
//         )),
//       ),
//       // ),
//       // ),
//       // Expanded(flex: dividerUse == true ? 1 : 0, child: Container()),
//       // ],
//       // ),
//     );
//   }
// }

// class NominalWidget extends StatelessWidget {
//   const NominalWidget(
//       {super.key,
//       required this.currencyController,
//       required this.errorMessageNotifier});

//   final TextEditingController currencyController;
//   final ValueNotifier<String?> errorMessageNotifier;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Text(
//             Strings.label_nominal,
//             style: AppTypography.semiBold16.copyWith(color: Colors.black),
//           ),
//         ),
//         ValueListenableBuilder<String?>(
//             valueListenable: errorMessageNotifier,
//             builder: (context, errorMessage, child) {
//               return BlocConsumer<TopUpBloc, TopupState>(
//                   listener: (context, state) {
//                 // state.nominalt;
//               }, builder: (context, state) {
//                 return CustomTextField(
//                   label: '',
//                   hint: 'Minimal   Rp10.000',
//                   onlyNumbers: true,
//                   controller: currencyController,
//                   errorText: errorMessage,
//                   onChanged: (value) {
//                     _selectedIndex = -1;
//                     if (int.parse(value) > 0 && int.parse(value) < 10000) {
//                       context.read<TopUpBloc>().add(
//                           HandleRadioButtonChangedEvent(
//                               nominal: value,
//                               tfBank: false,
//                               tfQris: false,
//                               jenisTf: state.jenisTf));
//                     } else if (int.parse(value) >= 10000 &&
//                         int.parse(value) <= 500000) {
//                       context.read<TopUpBloc>().add(
//                           HandleRadioButtonChangedEvent(
//                               nominal: value,
//                               tfBank: true,
//                               tfQris: true,
//                               jenisTf: state.jenisTf));
//                     } else if (int.parse(value) > 500000) {
//                       context.read<TopUpBloc>().add(
//                           HandleRadioButtonChangedEvent(
//                               nominal: value,
//                               tfBank: true,
//                               tfQris: false,
//                               jenisTf: state.jenisTf));
//                     }
//                   },
//                 );
//               });
//             })
//       ],
//     );
//   }
// }

// // ignore: must_be_immutable
// class BottomElevationContainer extends StatelessWidget {
//   final double elevationHeight;
//   final Widget content;
//   bool? status;
//   VoidCallback onTap;

//   BottomElevationContainer(
//       {required this.elevationHeight,
//       required this.content,
//       required this.status,
//       required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             height: elevationHeight,
//             child: status == false
//                 ? Container(
//                     decoration: BoxDecoration(
//                       color:
//                           Colors.white, // Change the background color as needed
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withValues(alpha:0.5),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset:
//                               Offset(0, 0), // Customize the shadow properties
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Container(
//                         color: Colors
//                             .white, // Change the background color as needed
//                         child: Container(
//                             margin: EdgeInsets.symmetric(horizontal: 20),
//                             height: 45,
//                             decoration: BoxDecoration(
//                                 color: onlyGray,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: content),
//                       ),
//                     ),
//                   )
//                 : Container(
//                     decoration: BoxDecoration(
//                       color:
//                           Colors.white, // Change the background color as needed
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withValues(alpha:0.5),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset:
//                               Offset(0, 0), // Customize the shadow properties
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Container(
//                         color: Colors
//                             .white, // Change the background color as needed
//                         child: InkWell(
//                           onTap: onTap,
//                           child: Container(
//                               margin: EdgeInsets.symmetric(horizontal: 20),
//                               height: 45,
//                               decoration: BoxDecoration(
//                                   color: primaryColor,
//                                   borderRadius: BorderRadius.circular(10)),
//                               child: content),
//                         ),
//                       ),
//                     ),
//                   )),
//       ],
//     );
//   }
// }
