import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Shared Superapp card for compact form rows.
class DsFormCard extends StatelessWidget {
  const DsFormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.grey200),
            children[i],
          ],
        ]),
      );
}

class DsFormRow extends StatelessWidget {
  const DsFormRow({
    super.key,
    required this.label,
    required this.child,
    this.requiredField = false,
    this.labelStyle,
  });

  final String label;
  final Widget child;
  final bool requiredField;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text.rich(
                TextSpan(text: label, children: [
                  if (requiredField)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ]),
                style: (labelStyle ?? AppTypography.bodySmRegular)
                    .copyWith(color: AppColors.alwaysBlack),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(flex: 7, child: child),
        ]),
      );
}
