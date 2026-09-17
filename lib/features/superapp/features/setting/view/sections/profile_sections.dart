import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../../domain/entities/setting_profile.dart';
import '../../widget/profile_form_card.dart';
import 'profile_section_fields.dart';

class SectionName extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String>? onUsernameChanged;
  final bool readOnly;
  const SectionName(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      this.onUsernameChanged,
      this.readOnly = false});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ProfileSectionHeading('Profile'),
        ProfileFormCard(children: [
          readOnly
              ? ProfileReadonlyField(
                  label: 'Nama Lengkap', value: profile.fullName)
              : ProfileTextField(
                  label: 'Nama Lengkap',
                  value: profile.fullName,
                  hint: 'Nama Lengkap',
                  onChanged: onNameChanged),
          readOnly
              ? ProfileReadonlyField(label: 'Username', value: profile.username)
              : ProfileTextField(
                  label: 'Username',
                  value: profile.username,
                  hint: 'Username',
                  onChanged: onUsernameChanged ?? (_) {})
        ])
      ]);
}

class SectionGender extends StatelessWidget {
  final SettingProfile profile;
  final VoidCallback onTap;
  final bool enabled;
  const SectionGender(
      {super.key,
      required this.profile,
      required this.onTap,
      this.enabled = true});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfilePickerField(
            label: 'Jenis Kelamin',
            value: profile.gender?.label,
            hint: 'Pilih Jenis Kelamin',
            onTap: onTap,
            enabled: enabled)
      ]);
}

class SectionContacts extends StatelessWidget {
  final SettingProfile profile;
  final VoidCallback onTap;
  final bool readOnly;
  final ValueChanged<String>? onPhoneChanged, onEmailChanged;
  const SectionContacts(
      {super.key,
      required this.profile,
      required this.onTap,
      this.onPhoneChanged,
      this.onEmailChanged,
      this.readOnly = false});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        readOnly
            ? ProfileReadonlyField(
                label: 'No. HP', value: profile.phone, onTap: onTap)
            : ProfileTextField(
                label: 'No. HP',
                value: profile.phone,
                hint: 'No. HP',
                onChanged: onPhoneChanged ?? (_) {}),
        readOnly
            ? ProfileReadonlyField(
                label: 'Email', value: profile.email, onTap: onTap)
            : ProfileTextField(
                label: 'Email',
                value: profile.email,
                hint: 'Email',
                onChanged: onEmailChanged ?? (_) {})
      ]);
}

class SectionAddress extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onChanged;
  const SectionAddress(
      {super.key, required this.profile, required this.onChanged});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfileTextField(
            label: 'Alamat Lengkap',
            value: profile.address,
            hint: 'Masukkan Alamat',
            onChanged: onChanged,
            lines: 4)
      ]);
}

class SectionBusinessLogo extends StatelessWidget {
  final SettingProfile profile;
  final VoidCallback onUpload;
  final bool enabled;
  const SectionBusinessLogo(
      {super.key,
      required this.profile,
      required this.onUpload,
      this.enabled = true});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(children: [
              ClipOval(
                  child: SizedBox(
                      width: 48,
                      height: 48,
                      child: profile.logoPath != null
                          ? Image.file(File(profile.logoPath!),
                              fit: BoxFit.cover)
                          : profile.logoUrl == null
                              ? SvgPicture.asset(
                                  'assets/images/superapp/home/ic_komerce_os.svg')
                              : Image.network(profile.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.store_outlined)))),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                  child:
                      Text('Bisnis Logo', style: AppTypography.bodySmRegular)),
              OutlinedButton.icon(
                  onPressed: enabled ? onUpload : null,
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alwaysBlack,
                      side: const BorderSide(color: AppColors.grey200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md))),
                  icon: const Icon(Icons.file_upload_outlined, size: 16),
                  label: const Text('Unggah'))
            ]))
      ]);
}

class SectionBusinessInfo extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onNameChanged, onPhoneChanged;
  final VoidCallback onLocationTap, onSectorTap;
  final bool enabled;
  const SectionBusinessInfo(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      required this.onPhoneChanged,
      required this.onLocationTap,
      required this.onSectorTap,
      this.enabled = true});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfileTextField(
            label: 'Nama Bisnis',
            value: profile.businessName,
            hint: 'Nama Bisnis',
            onChanged: onNameChanged,
            requiredField: true,
            maxLength: 30),
        ProfileTextField(
            label: 'No. HP Bisnis',
            value: profile.businessPhone,
            hint: 'No HP Bisnis',
            onChanged: onPhoneChanged,
            requiredField: true,
            phone: true),
        ProfilePickerField(
            label: 'Lokasi',
            value: profile.location?.label,
            hint: 'Masukkan Lokasi',
            onTap: onLocationTap,
            requiredField: true,
            enabled: enabled),
        ProfilePickerField(
            label: 'Sektor Bisnis',
            value: profile.businessSector?.label,
            hint: 'Pilih Sektor Bisnis',
            onTap: onSectorTap,
            enabled: enabled)
      ]);
}

class SectionBusiness extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onNameChanged, onPhoneChanged;
  final VoidCallback onUpload, onLocationTap, onSectorTap;
  final bool enabled;
  const SectionBusiness(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      required this.onPhoneChanged,
      required this.onUpload,
      required this.onLocationTap,
      required this.onSectorTap,
      this.enabled = true});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ProfileSectionHeading('Profile Bisnis'),
        SectionBusinessLogo(
            profile: profile, enabled: enabled, onUpload: onUpload),
        const SizedBox(height: AppSpacing.lg),
        SectionBusinessInfo(
            profile: profile,
            enabled: enabled,
            onNameChanged: onNameChanged,
            onPhoneChanged: onPhoneChanged,
            onLocationTap: onLocationTap,
            onSectorTap: onSectorTap),
      ]);
}
