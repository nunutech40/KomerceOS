import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

import '../../../common/global/widgets/debounce_button.dart';

class CustomButtonContact extends DebouncedButton {
  CustomButtonContact({
    Key? key,
    required VoidCallback onPressed,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : super(
          key: key,
          onPressed: onPressed,
          debounceDuration: debounceDuration,
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Ensure the row takes as little space as possible
            children: [
              SvgPicture.asset(
                'assets/images/ic-whatsapp.svg',
                width: 24.0,
                height: 24.0,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 4.0),
              const Text('Hubungi', style: AppTypography.regular14),
            ],
          ),
          buttonStyle: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0), // Reduced padding
          ),
        );
}
