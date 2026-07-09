import 'package:flutter/material.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/shopping/widget/button_filter.dart';

void bottomSheetFilter(
    BuildContext context, String currentStatus, String currentDate,
    {required void Function(String) onStatusClicked,
    required void Function(String) onDateClicked,
    required void Function() onResetClicked}) {
  String currentSelectStatus = currentStatus;
  String currentSelectDate = currentDate;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Image.asset('assets/images/rectangle-close.png'),
                  ),
                ),
                const SizedBox(
                  height: 14.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: SizedBox(
                          child: Text(
                            Strings.label_filter,
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () {
                          onResetClicked();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          Strings.label_reset,
                          style: TextStyle(
                            color: Color(0xFFE31A1A),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Text(
                              Strings.label_status,
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Semua',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_all,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Diajukan',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_requeted,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Disetujui',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_approved,
                      ),
                      const SizedBox(width: 12.0),
                      // Add more ButtonFilter widgets as needed
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Ditolak',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_rejected,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Dibatalkan',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_canceled,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectStatus == 'Selesai',
                        onPressed: (String type) {
                          onStatusClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_complete,
                      ),
                      const SizedBox(width: 12.0),
                    ],
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Text(
                              Strings.label_date,
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ButtonFilter(
                        isActive: currentSelectDate == 'Hari ini',
                        onPressed: (String type) {
                          onDateClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_today,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectDate == '7 Hari Terakhir',
                        onPressed: (String type) {
                          onDateClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_last_7_day,
                      ),
                      const SizedBox(width: 12.0),
                      ButtonFilter(
                        isActive: currentSelectDate == 'Semua',
                        onPressed: (String type) {
                          onDateClicked(type);
                          Navigator.pop(context);
                        },
                        text: Strings.label_all,
                      ),
                      const SizedBox(width: 12.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
