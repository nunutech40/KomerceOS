import 'package:flutter/material.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';

class TalentDetails extends StatefulWidget {
  const TalentDetails(
      {Key? key,
      required this.talents,
      required this.count,
      required this.index})
      : super(key: key);
  final List<TalentsSelectedDataModel>? talents;
  final double count;
  final int index;

  @override
  _TalentDetailsState createState() => _TalentDetailsState();
}

class CustomTextRow extends StatelessWidget {
  final String title;
  final String content;
  final double right;
  final double left;
  final double bottom;
  final double top;

  const CustomTextRow({super.key, 
    required this.title,
    required this.content,
    required this.right,
    required this.left,
    required this.bottom,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(left, top, right, bottom),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14.0,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }
}

class _TalentDetailsState extends State<TalentDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextRow(
            title: Strings.label_talent_name,
            content: widget.talents?[widget.index].talentName ?? '',
            right: 24,
            left: 24,
            bottom: 0,
            top: 16),
        CustomTextRow(
            title: Strings.label_hire_date,
            content: widget.talents?[widget.index].hiredDate ?? '',
            right: 24,
            left: 24,
            bottom: 0,
            top: 24),
        CustomTextRow(
            title: Strings.label_duration,
            content: widget.talents?[widget.index].duration ?? '',
            right: 24,
            left: 24,
            bottom: 0,
            top: 24),
      ],
    );
  }
}
