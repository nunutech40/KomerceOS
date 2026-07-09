import 'package:flutter/material.dart';
import 'package:komtim_partner/features/attendance/widget/body_card_attendance.dart';
import 'package:komtim_partner/features/attendance/widget/head_card_attendance.dart';

// ignore: must_be_immutable
class CardAttendance extends StatefulWidget {
  String? name;
  String? type;
  String? date;
  String? imagesClockIn;
  String? imagesClockOut;
  String? clockIn;
  String? clockOut;
  int? index;

  CardAttendance(
      {super.key,
      required this.name,
      required this.type,
      required this.date,
      required this.imagesClockIn,
      required this.imagesClockOut,
      required this.clockIn,
      required this.clockOut,
      required this.index});

  @override
  State<CardAttendance> createState() => _CardAttendanceState();
}

class _CardAttendanceState extends State<CardAttendance> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          HeadCardAttendance(
            name: widget.name,
            type: widget.type,
            date: widget.date,
          ),
          BodyCardAttendance(
            clockIn: widget.clockIn,
            clockOut: widget.clockOut,
            imagesClockIn: widget.imagesClockIn,
            imagesClockOut: widget.imagesClockOut,
          )
        ],
      ),
    );
  }
}
