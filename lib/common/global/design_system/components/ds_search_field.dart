import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';

class DsSearchField extends StatelessWidget {
  const DsSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Cari...',
    this.onChanged,
    this.onSubmitted,
    this.iconPath = 'assets/images/ic_search_new.svg',
    this.suffixIcon,
    this.enabled = true,
    this.height = 44,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? iconPath;
  final Widget? suffixIcon;
  final bool enabled;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.grey200), // border halus
        boxShadow: [
          BoxShadow(
            color: AppColors.alwaysBlack
                .withValues(alpha: 0.04), // shadow tipis & lembut
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.alwaysBlack,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: suffixIcon ??
                (iconPath != null
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          iconPath!,
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : null),
            // Set border bawaan TextField ke InputBorder.none agar border diatur oleh Container luar
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
