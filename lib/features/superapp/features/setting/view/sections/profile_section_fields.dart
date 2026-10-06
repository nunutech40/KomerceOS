import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../../domain/entities/setting_profile.dart';
import '../../widget/profile_form_card.dart';

class ProfileTextField extends StatefulWidget {
  final String label, value, hint;
  final ValueChanged<String> onChanged;
  final bool requiredField, phone, numeric;
  final int? maxLength;
  final int lines;
  final String? Function(String?)? validator;
  const ProfileTextField(
      {super.key,
      required this.label,
      required this.value,
      required this.hint,
      required this.onChanged,
      this.requiredField = false,
      this.maxLength,
      this.lines = 1,
      this.phone = false,
      this.numeric = false,
      this.validator});

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ProfileTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.value) return;
    _controller.value = TextEditingValue(
      text: widget.value,
      selection: TextSelection.collapsed(offset: widget.value.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProfileFormRow(
      label: widget.label,
      requiredField: widget.requiredField,
      child: DsTextField(
          key: ValueKey(widget.label),
          controller: _controller,
          hintText: widget.hint,
          maxLength: widget.maxLength,
          lines: widget.lines,
          keyboardType: widget.numeric
              ? TextInputType.number
              : widget.phone
                  ? TextInputType.phone
                  : widget.lines > 1
                      ? TextInputType.multiline
                      : TextInputType.text,
          inputFormatters: widget.numeric
              ? [FilteringTextInputFormatter.digitsOnly]
              : widget.phone
                  ? [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return RegExp(r'^\+?[0-9]{0,15}$')
                                .hasMatch(newValue.text)
                            ? newValue
                            : oldValue;
                      }),
                    ]
                  : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (text) {
            final fieldError = widget.validator?.call(text);
            if (fieldError != null) return fieldError;
            if (widget.requiredField && (text == null || text.trim().isEmpty)) {
              return 'Wajib diisi';
            }
            if (widget.phone &&
                text != null &&
                text.isNotEmpty &&
                !isValidPhoneNumber(text)) {
              return 'Masukkan 8–15 digit nomor HP';
            }
            return null;
          },
          onChanged: widget.onChanged));
}

class ProfileReadonlyField extends StatelessWidget {
  final String label, value;
  final VoidCallback? onTap;
  const ProfileReadonlyField(
      {super.key, required this.label, required this.value, this.onTap});
  @override
  Widget build(BuildContext context) => ProfileFormRow(
      label: label,
      child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(value.isEmpty ? '—' : value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmRegular
                      .copyWith(color: AppColors.grey600)))));
}

class ProfilePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final bool requiredField, enabled;
  const ProfilePickerField(
      {super.key,
      required this.label,
      required this.value,
      required this.hint,
      required this.onTap,
      this.requiredField = false,
      this.enabled = true});
  @override
  Widget build(BuildContext context) => ProfileFormRow(
      label: label,
      requiredField: requiredField,
      child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Expanded(
                    child: Text(value ?? hint,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmRegular.copyWith(
                            color: value == null
                                ? AppColors.grey600
                                : AppColors.alwaysBlack))),
                if (enabled)
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.grey600)
              ]))));
}

class ProfileSectionHeading extends StatelessWidget {
  final String title;
  const ProfileSectionHeading(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding:
          const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(title,
          style:
              AppTypography.bodyMdMedium.copyWith(color: AppColors.grey600)));
}
