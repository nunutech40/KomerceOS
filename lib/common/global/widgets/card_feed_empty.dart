import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

class CardFeedEmpty extends StatelessWidget {
  final String image;
  final String title;
  final String body;
  final Color? colorImage;
  const CardFeedEmpty({
    super.key,
    required this.image,
    required this.title,
    required this.body,
    this.colorImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: AppTypography.regular16
                .copyWith(color: blackColors33, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            body,
            style: AppTypography.regular12
                .copyWith(color: darkGray, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
