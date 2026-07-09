import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/styles.dart';

class SmallIconCard extends StatelessWidget {
  final String text;
  final String iconAsset;
  final Function() onTap;
  final bool isActive;

  const SmallIconCard(
      {super.key, required this.text,
      required this.iconAsset,
      required this.onTap,
      this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: isActive ? onTap : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Card(
                  elevation: 3.0,
                  surfaceTintColor: Colors.white,
                  child: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: Center(
                        child: isActive == false
                            ? SvgPicture.asset(iconAsset,
                                width: 24.0,
                                height: 24.0,
                                colorFilter: ColorFilter.mode(
                                    isActive ? primaryColor : inActiveGray,
                                    BlendMode.srcIn))
                            : SvgPicture.asset(
                                iconAsset,
                                width: 24.0,
                                height: 24.0,
                              )),
                  )),
            ),
            const SizedBox(height: 8.0),
            Text(
              textAlign: TextAlign.center,
              text,
              maxLines: 2,
              style: isActive == true
                  ? AppTypography.regular12
                  : AppTypography.regular12Grey,
            ),
          ],
        ),
      ),
    );
  }
}
