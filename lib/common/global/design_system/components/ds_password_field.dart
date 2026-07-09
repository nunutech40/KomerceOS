import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

class DsPasswordField extends StatefulWidget {
  final String label;
  final Widget? topTrailing;
  final TextEditingController controller;
  final String? errorText; // Menggantikan bool isError
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const DsPasswordField({
    super.key,
    required this.label,
    this.topTrailing,
    required this.controller,
    this.errorText,
    this.hintText = 'Masukkan password...', // Default bisa dioverride parent
    this.onChanged,
  });

  @override
  State<DsPasswordField> createState() => _DsPasswordFieldState();
}

/// Formatter untuk mencegah paste (input lebih dari 1 karakter sekaligus)
class _NoPasteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika karakter bertambah lebih dari 1 sekaligus → paste, tolak
    if (newValue.text.length - oldValue.text.length > 1) {
      return oldValue;
    }
    return newValue;
  }
}

class _DsPasswordFieldState extends State<DsPasswordField> {
  // Uncontrolled state: diatur secara internal oleh komponen ini saja
  bool _isObscured = true;

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Evaluasi status error
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTypography.labelMdSemiBold.copyWith(
                color: AppColors.grey800,
              ),
            ),
            if (widget.topTrailing != null) widget.topTrailing!,
          ],
        ),
        const SizedBox(height: AppSpacing.md2),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: _isObscured,
          enableInteractiveSelection: false,
          enableSuggestions: false,
          autocorrect: false,
          contextMenuBuilder: (context, editableTextState) {
            return const SizedBox.shrink();
          },
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            _NoPasteFormatter(),
          ],
          style: AppTypography.bodyMdRegular.copyWith(
            color: AppColors.grey800,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grey600,
              ),
              onPressed: _toggleObscure,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.errorBase : AppColors.grey400,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.errorBase : AppColors.primaryBase,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.bodySmRegular.copyWith(
              color: AppColors.errorBase,
            ),
          ),
        ]
      ],
    );
  }
}