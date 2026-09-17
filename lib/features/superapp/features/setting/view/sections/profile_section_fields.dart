import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../../widget/profile_form_card.dart';

class ProfileTextField extends StatelessWidget {
  final String label, value, hint;
  final ValueChanged<String> onChanged;
  final bool requiredField, phone;
  final int? maxLength;
  final int lines;
  const ProfileTextField(
      {super.key,
      required this.label,
      required this.value,
      required this.hint,
      required this.onChanged,
      this.requiredField = false,
      this.maxLength,
      this.lines = 1,
      this.phone = false});
  @override
  Widget build(BuildContext context) => ProfileFormRow(
      label: label,
      requiredField: requiredField,
      child: TextFormField(
          key: ValueKey(label),
          initialValue: value,
          style: AppTypography.bodySmRegular
              .copyWith(color: AppColors.alwaysBlack),
          maxLength: maxLength,
          minLines: lines,
          maxLines: lines,
          keyboardType: phone
              ? TextInputType.phone
              : lines > 1
                  ? TextInputType.multiline
                  : TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (text) {
            if (requiredField && (text == null || text.trim().isEmpty)) {
              return 'Wajib diisi';
            }
            if (phone &&
                text != null &&
                text.isNotEmpty &&
                !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(text.trim())) {
              return 'Masukkan 8–15 digit nomor HP';
            }
            return null;
          },
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodySmRegular
                  .copyWith(color: AppColors.grey600),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12)),
          onChanged: onChanged));
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
