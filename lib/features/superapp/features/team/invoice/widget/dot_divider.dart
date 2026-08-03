import 'package:flutter/material.dart';

import '../../../../../../common/styles.dart';

class DotDivider extends StatelessWidget {
  final double width;
  final double height;
  final double gap;
  final Color color;
  final double lineHeight;

  const DotDivider(
      {super.key, this.height = 1.0,
      this.color = onlyGray,
      this.width = 4.0,
      this.gap = 2.0,
      this.lineHeight = 10.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = width;
        final dashHeight = height;
        final dashCount = (boxWidth / dashWidth).floor();
        return SizedBox(
          height: (lineHeight * 2) + height,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: dashCount,
            itemBuilder: (BuildContext context, int index) => Center(
              child: Container(
                width: dashWidth,
                height: dashHeight,
                margin:
                    EdgeInsets.symmetric(vertical: lineHeight, horizontal: gap),
                decoration: BoxDecoration(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}
