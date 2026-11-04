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
    this.labelFlex = 4,
    this.valueFlex = 7,
    this.verticalPadding = AppSpacing.xs,
    this.contentVerticalPadding = 12,
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
  final int labelFlex;
  final int valueFlex;
  final double verticalPadding;
  final double contentVerticalPadding;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsFormRow(
            label: label,
            requiredField: requiredField,
            labelStyle: textStyle,
            labelFlex: labelFlex,
            valueFlex: valueFlex,
            verticalPadding: verticalPadding,
            contentVerticalPadding: contentVerticalPadding,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: contentVerticalPadding),
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
