import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_next_unhire.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';

class CustomShowmodalReportPerformanceWeek extends StatefulWidget {
  final BuildContext? context;
  DateTime? selectedDate;
  int? value;
  String? textEditor;
  final List<ReportPerformanceProductModel> listProduct;
  CustomShowmodalReportPerformanceWeek({
    super.key,
    this.context,
    this.selectedDate,
    this.value,
    this.textEditor,
    required this.listProduct,
  });

  @override
  State<CustomShowmodalReportPerformanceWeek> createState() =>
      _CustomShowmodalReportPerformanceWeekState();
}

class _CustomShowmodalReportPerformanceWeekState
    extends State<CustomShowmodalReportPerformanceWeek> {
  String? selectProductId;
  late List<ReportPerformanceProductModel> _listProduct;

  @override
  void initState() {
    super.initState();
    _listProduct = widget.listProduct;
    if (_listProduct.isNotEmpty) {
      selectProductId = _listProduct.first.id?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                        child:
                            SvgPicture.asset("assets/images/ic_rectangle.svg")),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 12),
                  child: Text(
                    "Pilih Jenis Produk",
                    textAlign: TextAlign.center,
                    style: AppTypography.interSemiBold16,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: backgroundContainerColor),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(8.0),
                            menuMaxHeight: 150.0,
                            hint: const Text(
                              'Semua',
                              style: AppTypography.regular14inActive,
                            ),
                            style: AppTypography.regular14black,
                            value: selectProductId,
                            items: _listProduct.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.id?.toString(),
                                child: Text(item.name ?? ''),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectProductId = newValue;
                              });
                            },
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: SvgPicture.asset(
                                  "assets/images/ic_arrow_bottom.svg",
                                  width: 20,
                                  height: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 7.5),
                          child: CustomOutlineButton(
                            text: 'Reset Filter',
                            onPressed: () {
                              setState(() {
                                selectProductId = '';
                              });
                              Navigator.of(context)
                                  .pop({'select_product': selectProductId});
                            },
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 7.5),
                          child: CustomButtonNextUnhire(
                            text: 'Terapkan Filter',
                            onPressed: () => Navigator.of(context)
                                .pop({'select_product': selectProductId}),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardRadioButton extends StatelessWidget {
  final String? name;
  final int? value;
  final int? groudValue;
  final Function(int?)? onTap;
  final VoidCallback? onTapp;
  const CardRadioButton(
      {super.key,
      this.name,
      this.value,
      this.groudValue,
      this.onTapp,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: backgroundContainerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTapp,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name ?? "",
                  style: AppTypography.regular14,
                ),
                Theme(
                  data: ThemeData(unselectedWidgetColor: e2Gray),
                  child: Radio(
                    value: value!,
                    groupValue: groudValue,
                    onChanged: onTap,
                    activeColor: primaryColor,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
