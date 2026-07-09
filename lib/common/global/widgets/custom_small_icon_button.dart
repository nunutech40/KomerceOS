import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

import 'debounce_button.dart';

class CustomButtonSmallIcon extends DebouncedButton {
  final String text;
  final String iconAsset;
  @override
  final bool isActive; // Add this line
  final Color txColor;
  final Color bgColor;

  CustomButtonSmallIcon({
    Key? key,
    required this.text,
    required VoidCallback onPressed,
    required this.iconAsset,
    this.isActive = true, // Add this line
    this.txColor = primaryColor,
    this.bgColor = Colors.white,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : super(
          key: key,
          onPressed: onPressed,
          debounceDuration: debounceDuration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isActive == false
                  ? SvgPicture.asset(iconAsset,
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          isActive ? Colors.white : inActiveGray,
                          BlendMode.srcIn))
                  : SvgPicture.asset(
                      iconAsset,
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.cover,
                      color: txColor,
                    ),
              const SizedBox(width: 5.0),
              Text(text,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: txColor)),
            ],
          ),
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor:
                isActive ? bgColor : Colors.white, // Use isActive here
            foregroundColor: primaryColor,
            side: BorderSide(
                color: isActive ? primaryColor : inActiveGray, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 5.0, horizontal: 12.0), // Reduced padding
          ),
        );

  @override
  _CustomButtonSmallIconState createState() => _CustomButtonSmallIconState();
}

class _CustomButtonSmallIconState extends DebouncedButtonState {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.isActive ? handleTap : null,
      style: widget.buttonStyle,
      child: widget.child,
    );
  }
}
