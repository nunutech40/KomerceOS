import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart' as appColors;

import '../../../../../../common/styles.dart';
import '../../../../../../common/time_convert.dart';

// ignore: must_be_immutable
class HeadCardAttendance extends StatelessWidget {
  String? name;
  String? type;
  String? date;
  HeadCardAttendance(
      {super.key, required this.name, required this.type, required this.date});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1,
          color: appColors.e2Gray,
        ))),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  name ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTypography.regular120AOA,
                ),
              ),
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dateConvert(date),
                    style: AppTypography.regular12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
