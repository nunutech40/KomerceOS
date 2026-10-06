import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';

/// Plain text input used inside form rows across Superapp.
/// Labels, validation rules, and surrounding cards belong to the caller.
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.maxLength,
    this.lines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final int? maxLength;
  final int lines;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        style:
            AppTypography.bodySmRegular.copyWith(color: AppColors.alwaysBlack),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        autovalidateMode: autovalidateMode,
        maxLength: maxLength,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTypography.bodySmRegular.copyWith(color: AppColors.grey600),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: onChanged,
      );
}
