import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_next_unhire.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomShowmodalReportPerformanceToday extends StatefulWidget {
  final BuildContext? context;
  final DateTime? selectedDate;
  final int? value;
  final String? textEditor;
  final String? firstDate;
  final String? lastDate;
  const CustomShowmodalReportPerformanceToday(
      {super.key,
      this.context,
      this.selectedDate,
      this.value,
      this.textEditor,
      this.firstDate,
      this.lastDate});

  @override
  State<CustomShowmodalReportPerformanceToday> createState() =>
      _CustomShowmodalReportPerformanceTodayState();
}

class _CustomShowmodalReportPerformanceTodayState
    extends State<CustomShowmodalReportPerformanceToday> {
  int? value;

  TextEditingController firstDateController = TextEditingController();
  TextEditingController lastDateController = TextEditingController();

  DateTime _initialDateFromController(String dateText) {
    if (dateText.isEmpty) return DateTime.now();
    try {
      return formatter.parse(dateText);
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context, String statusDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: statusDate == 'first'
          ? _initialDateFromController(firstDateController.text)
          : _initialDateFromController(lastDateController.text),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        DateTime.now().day,
      ),
      lastDate: DateTime.now(),
      helpText: 'Pilih Range Tanggal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(color: Colors.white)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      statusFilter = "custom";
      value = 2;
      setState(() {
        final formattedDate = formatter.format(picked);
        if (statusDate == "first") {
          firstDateController.text = formattedDate;
        } else if (statusDate == "last") {
          lastDateController.text = formattedDate;
        }
      });
    }
  }

  var now = DateTime.now();
  var weekNowDate = DateTime.now().subtract(const Duration(days: 7));
  var monthNowDate = DateTime(
    DateTime.now().year,
    DateTime.now().month - 1,
    DateTime.now().day,
  );
  var formatter = DateFormat('yyyy-MM-dd');

  getDate(String status) {
    if (status == "day") {
      firstDateController.text = formatter.format(now);
      lastDateController.text = formatter.format(now);
      statusFilter = "today";
      setState(() {});
    } else if (status == "week") {
      firstDateController.text = formatter.format(weekNowDate);
      lastDateController.text = formatter.format(now);
      statusFilter = "week";
      setState(() {});
    } else if (status == "month") {
      firstDateController.text = formatter.format(monthNowDate);
      lastDateController.text = formatter.format(now);
      statusFilter = "month";
      setState(() {});
    }
  }

  String statusFilter = '';

  int height = 0;

  @override
  void initState() {
    super.initState();
    value = widget.value ?? 0;

    if ((widget.firstDate ?? '').isNotEmpty) {
      firstDateController.text = widget.firstDate!;
    }

    if ((widget.lastDate ?? '').isNotEmpty) {
      lastDateController.text = widget.lastDate!;
    }

    if (value == 2) {
      statusFilter = 'custom';
    } else if (value == 1) {
      statusFilter = 'today';
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
                  padding: EdgeInsets.only(top: 32, bottom: 24),
                  child: Text(
                    "Pilih Tanggal",
                    textAlign: TextAlign.center,
                    style: AppTypography.regular600,
                  ),
                ),
                CardRadioButton(
                  name: "Hari Ini",
                  value: 1,
                  groudValue: value,
                  onTapp: () {
                    setState(() {
                      value = 1;
                      firstDateController.text = '';
                      lastDateController.text = '';
                      getDate('day');
                    });
                  },
                  onTap: (valueRa) {
                    setState(() {
                      value = valueRa as int;
                      firstDateController.text = '';
                      lastDateController.text = '';
                      getDate('day');
                    });
                  },
                ),
                CardRadioButton(
                  name: "Custom Tanggal",
                  value: 2,
                  groudValue: value,
                  onTapp: () {
                    setState(() {
                      firstDateController.text = '';
                      lastDateController.text = '';
                      value = 2;
                    });
                  },
                  onTap: (valueRa) {
                    setState(() {
                      value = valueRa as int;
                      firstDateController.text = '';
                      lastDateController.text = '';
                    });
                  },
                ),
                value == 2
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Mulai dari",
                                    textAlign: TextAlign.center,
                                    style: AppTypography.regular12,
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: backgroundContainerColor,
                                          border: Border.all(
                                              color:
                                                  firstDateController.text != ''
                                                      ? backgroundContainerColor
                                                      : errorColor)),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectDate(context, 'first');
                                          });
                                        },
                                        child: TextField(
                                          controller: firstDateController,
                                          style: AppTypography.regular12,
                                          decoration: const InputDecoration(
                                            enabled: false,
                                            border: InputBorder.none,
                                            hintStyle:
                                                AppTypography.regular14inActive,
                                            hintText: 'tgl/bln/thn',
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sampai dengan",
                                    textAlign: TextAlign.center,
                                    style: AppTypography.regular12,
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: backgroundContainerColor,
                                          border: Border.all(
                                              color:
                                                  lastDateController.text != ''
                                                      ? backgroundContainerColor
                                                      : errorColor)),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectDate(context, 'last');
                                          });
                                        },
                                        child: TextField(
                                          controller: lastDateController,
                                          style: AppTypography.regular12,
                                          decoration: const InputDecoration(
                                            enabled: false,
                                            border: InputBorder.none,
                                            hintStyle:
                                                AppTypography.regular14inActive,
                                            hintText: 'tgl/bln/thn',
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                value == 2
                    ? Container(
                        child: firstDateController.text == '' ||
                                lastDateController.text == ''
                            ? Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                        "assets/images/ic_warning_circle.svg"),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    firstDateController.text == ''
                                        ? const Text(
                                            "Kamu belum memilih tanggal mulai",
                                            textAlign: TextAlign.center,
                                            style: AppTypography.regular12Error,
                                          )
                                        : const Text(
                                            "Kamu belum memilih tanggal akhir",
                                            textAlign: TextAlign.center,
                                            style: AppTypography.regular12Error,
                                          )
                                  ],
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.only(top: 12),
                              ),
                      )
                    : Container(),
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
                              value = 0;
                              firstDateController.text = formatter.format(now);
                              lastDateController.text = formatter.format(now);
                              statusFilter = '';
                              Navigator.of(context).pop({
                                'firstDate': firstDateController.text,
                                'lastDate': lastDateController.text,
                                'statusFilter': 'all',
                                'value': 0,
                                'textEditor': ''
                              });
                            },
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 7.5),
                          child: firstDateController.text != '' &&
                                  lastDateController.text != ''
                              ? CustomButtonNextUnhire(
                                  text: 'Terapkan Filter',
                                  onPressed: () => Navigator.of(context).pop({
                                    'firstDate': firstDateController.text,
                                    'lastDate': lastDateController.text,
                                    'statusFilter': statusFilter,
                                    'value': value,
                                    'textEditor': widget.textEditor
                                  }),
                                )
                              : CustomButtonNextUnhire(
                                  text: 'Terapkan Filter',
                                  isActive: false,
                                  onPressed: () {}),
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
