import 'package:flutter/material.dart';

import '../../../common/styles.dart';
import '../../../common/time_convert.dart';

// ignore: must_be_immutable
class FailAttendanceCard extends StatefulWidget {
  String? name;
  String? date;
  String? deskripsi;
  int? index;
  FailAttendanceCard(
      {super.key, this.name, this.date, this.deskripsi, this.index});

  @override
  State<FailAttendanceCard> createState() => _FailAttendanceCardState();
}

class _FailAttendanceCardState extends State<FailAttendanceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin:
          EdgeInsets.only(left: 4, right: 4, top: widget.index == 0 ? 0 : 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 1,
            )
          ],
          border: Border.all(width: 0.1),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 0.5))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            widget.name ?? "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: AppTypography.regular12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        dateConvertWithT(widget.date),
                        style: AppTypography.regular12,
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Deskripsi",
                  style: AppTypography.regular12Primary,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  widget.deskripsi ?? "",
                  style: AppTypography.regular12,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
