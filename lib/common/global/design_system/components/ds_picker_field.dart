import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';
import 'ds_form_card.dart';

/// Selection row matching the editable form rows used across Superapp.
class DsPickerField extends StatelessWidget {
  const DsPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.requiredField = false,
    this.enabled = true,
    this.errorText,
    this.textStyle,
    this.trailingIcon = Icons.keyboard_arrow_down,
  });

  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final bool requiredField;
  final bool enabled;
  final String? errorText;
  final TextStyle? textStyle;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsFormRow(
            label: label,
            requiredField: requiredField,
            labelStyle: textStyle,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      value ?? hint,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (textStyle ?? AppTypography.bodySmRegular).copyWith(
                        color: value == null
                            ? AppColors.grey600
                            : AppColors.alwaysBlack,
                      ),
                    ),
                  ),
                  if (enabled)
                    Icon(
                      trailingIcon,
                      size: 18,
                      color: AppColors.grey600,
                    ),
                ]),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                errorText!,
                style: AppTypography.bodySmRegular
                    .copyWith(color: AppColors.errorBase),
              ),
            ),
        ],
      );
}
