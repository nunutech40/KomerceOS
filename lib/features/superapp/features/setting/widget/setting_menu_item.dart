import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class SettingMenuItem extends StatelessWidget {
  final Widget leadingIcon;
  final Color leadingBackgroundColor;
  final String title;
  final String? trailingText;
  final Color titleColor;
  final Color trailingIconColor;
  final BorderRadius? borderRadius;
  final VoidCallback onTap;

  const SettingMenuItem({
    super.key,
    required this.leadingIcon,
    this.leadingBackgroundColor = const Color(0xFFF5F5F5),
    required this.title,
    this.trailingText,
    this.titleColor = const Color(0xFF222222),
    this.trailingIconColor = const Color(0xFF828282),
    this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: leadingBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: leadingIcon),
            ),
            const SizedBox(width: 14),
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyMdMedium.copyWith(
                  color: titleColor,
                ),
              ),
            ),
            // Trailing section
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTypography.bodyMdMedium.copyWith(
                  color: AppColors.alwaysBlack,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: titleColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
