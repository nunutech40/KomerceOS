import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class ProfileFormCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileFormCard({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
            color: AppColors.alwaysWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0D000000), offset: Offset(0, 2), blurRadius: 2)
            ]),
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.grey200),
            children[i],
          ]
        ]),
      );
}

class ProfileFormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool requiredField;
  const ProfileFormRow(
      {super.key,
      required this.label,
      required this.child,
      this.requiredField = false});
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
                              text: ' *', style: TextStyle(color: Colors.red)),
                      ]),
                      style: AppTypography.bodySmRegular
                          .copyWith(color: AppColors.alwaysBlack)))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(flex: 7, child: child),
        ]),
      );
}
