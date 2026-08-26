import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../common/styles.dart';

class CardEmptyList extends StatefulWidget {
  const CardEmptyList({
    super.key,
  });

  @override
  State<CardEmptyList> createState() => _CardEmptyListState();
}

class _CardEmptyListState extends State<CardEmptyList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          SizedBox(
              height: 150,
              width: 150,
              child: SvgPicture.asset("assets/images/ic_not_found.svg")),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Belum ada talent yang hadir",
            textAlign: TextAlign.center,
            style: AppTypography.regular14,
          ),
        ],
      ),
    );
  }
}
