import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../common/styles.dart';

class CardSearchEmptyList extends StatefulWidget {
  VoidCallback onPressed;
  CardSearchEmptyList({
    super.key,
    required this.onPressed,
  });

  @override
  State<CardSearchEmptyList> createState() => _CardSearchEmptyListState();
}

class _CardSearchEmptyListState extends State<CardSearchEmptyList> {
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
            "Oops, talent tidak ditemukan",
            textAlign: TextAlign.center,
            style: AppTypography.regularBold,
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Coba Reset atau ubah filter kamu ya",
            textAlign: TextAlign.center,
            style: AppTypography.regular14,
          ),
          const SizedBox(
            height: 15,
          ),
          SafeArea(
              child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                width: MediaQuery.of(context).size.width,
                height: 45,
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: widget.onPressed,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 11.0, horizontal: 24.0),
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Reset Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          )),
        ],
      ),
    );
  }
}
