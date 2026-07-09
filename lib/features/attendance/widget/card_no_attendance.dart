import 'package:flutter/material.dart';
import 'package:komtim_partner/common/time_convert.dart';

import '../../../common/styles.dart';

// ignore: must_be_immutable
class CardNoAttendance extends StatefulWidget {
  String? name;
  String? date;
  final int? length;
  final int index;
  CardNoAttendance(
      {super.key,
      this.name,
      this.date,
      required this.length,
      required this.index});

  @override
  State<CardNoAttendance> createState() => _CardNoAttendanceState();
}

class _CardNoAttendanceState extends State<CardNoAttendance> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: widget.index == 0
            ? const Radius.circular(5)
            : const Radius.circular(0),
        topRight: widget.index == 0
            ? const Radius.circular(5)
            : const Radius.circular(0),
        bottomRight: widget.length == (widget.index + 1)
            ? const Radius.circular(5)
            : const Radius.circular(0),
        bottomLeft: widget.length == (widget.index + 1)
            ? const Radius.circular(5)
            : const Radius.circular(0),
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: widget.index == 0
                  ? const Radius.circular(5)
                  : const Radius.circular(0),
              topRight: widget.index == 0
                  ? const Radius.circular(5)
                  : const Radius.circular(0),
              bottomRight: widget.length == (widget.index + 1)
                  ? const Radius.circular(5)
                  : const Radius.circular(0),
              bottomLeft: widget.length == (widget.index + 1)
                  ? const Radius.circular(5)
                  : const Radius.circular(0),
            ),
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
          ],
        ),
      ),
    );
  }
}
