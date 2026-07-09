import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/styles.dart';

class SmallIconCardNotife extends StatelessWidget {
  final String text;
  final String iconAsset;
  final String textNotif;
  final bool isActive;

  final Function() onTap;

  const SmallIconCardNotife({super.key, 
    required this.text,
    required this.iconAsset,
    required this.textNotif,
    required this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Column(
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
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                text,
                style: AppTypography.regular12,
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive == true ? orangeColor : inActiveGray,
              ),
              child: Center(
                child: Text(
                  textNotif,
                  style: isActive == true
                      ? AppTypography.small14White
                      : AppTypography.small14Grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
