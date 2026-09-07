import 'package:flutter/material.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/ratetalent/widget/small_rating.dart';

import '../../../common/styles.dart';

class RatingInfoWidget extends StatelessWidget {
  const RatingInfoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: greenD6F1,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                Strings.label_rating_method,
                style: AppTypography.semiBold16,
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Text(
                'Tandai semua talent dan talent lead, kemudian pilih rate yang mau kamu berikan.',
                style: AppTypography.regular12,
              ),
              const SizedBox(
                height: 16.0,
              ),
              const Text(
                Strings.label_rating,
                style: AppTypography.semiBold12,
              ),
              const SizedBox(
                height: 8.0,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: SmallRating(rating: '1')),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(child: SmallRating(rating: '2')),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(child: SmallRating(rating: '3')),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(child: SmallRating(rating: '4')),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(child: SmallRating(rating: '5'))
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Strings.label_bad,
                    style: AppTypography.regular12.copyWith(color: errorColor),
                  ),
                  Text(
                    Strings.label_very_good,
                    style: AppTypography.regular12.copyWith(color: green30A),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
