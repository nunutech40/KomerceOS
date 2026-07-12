import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class AppInfoCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;

  const AppInfoCard(
      {super.key,
      required this.children,
      this.padding = const EdgeInsets.all(20),
      this.borderRadius = const BorderRadius.all(Radius.circular(24)),
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class HighlightText extends StatelessWidget {
  final String prefix;
  final String highlight;
  final String suffix;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightText({
    super.key,
    required this.prefix,
    required this.highlight,
    this.suffix = '',
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ??
        AppTypography.bodyMdRegular.copyWith(
          color: AppColors.textDark,
        );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: highlight,
            style: highlightStyle ??
                baseStyle.copyWith(
                  color: AppColors.primaryBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}
