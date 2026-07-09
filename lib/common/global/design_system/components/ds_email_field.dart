import 'package:flutter/material.dart';

import '../design_system.dart'; // import app_colors, app_spacing, dll

class DsEmailInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText; 
  final String? hintText; 
  final ValueChanged<String>? onChanged;

  const DsEmailInput({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.hintText = 'Masukkan email...', 
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMdSemiBold.copyWith(
            color: AppColors.grey800,
          ),
        ),
        const SizedBox(height: AppSpacing.md2),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMdRegular.copyWith(
            color: AppColors.grey800,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            // PERBAIKAN 1: Gunakan token untuk warna dan radius
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.errorBase : AppColors.grey400, // Ganti Colors.red & Colors.grey
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md), // Ganti angka 8
            ),
            // PERBAIKAN 2: Biasanya warna saat focus adalah warna primary, bukan grey
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.errorBase : AppColors.primaryBase, 
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md), // Ganti angka 8
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            // PERBAIKAN 3: Gunakan typography dari design system
            style: AppTypography.bodySmRegular.copyWith(
              color: AppColors.errorBase,
            ),
          ),
        ],
      ],
    );
  }
}