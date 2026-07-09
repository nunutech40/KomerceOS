
import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class SaldoWidget extends StatelessWidget {
  final String text1;
  final String text2;

  const SaldoWidget({super.key, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor, 
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            text1,
            style: AppTypography.regular14.copyWith(color: Colors.white),
          ),
          Text(
            text2,
            style: AppTypography.bold16.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
