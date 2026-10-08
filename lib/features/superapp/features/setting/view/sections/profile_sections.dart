import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../../domain/entities/setting_profile.dart';
import '../../bloc/setting_profile_state.dart';
import '../../widget/profile_form_card.dart';
import 'profile_section_fields.dart';

class SectionName extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onReadOnlyTap;
  final bool enabled;
  const SectionName(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      required this.onReadOnlyTap,
      this.enabled = true});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ProfileSectionHeading('Profile'),
        ProfileFormCard(children: [
          ProfileTextField(
              label: 'Nama Lengkap',
              value: profile.fullName,
              hint: 'Nama Lengkap',
              maxLength: 60,
              enabled: enabled,
              requiredField: true,
              validator: (value) => isValidProfileName(value ?? '')
                  ? null
                  : 'Nama harus 3–60 karakter dan hanya huruf',
              onChanged: onNameChanged),
          ProfileReadonlyField(
              label: 'Username', value: profile.username, onTap: onReadOnlyTap)
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
  const SectionContacts(
      {super.key, required this.profile, required this.onTap});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfileReadonlyField(
            label: 'No. HP', value: profile.phone, onTap: onTap),
        ProfileReadonlyField(label: 'Email', value: profile.email, onTap: onTap)
      ]);
}

class SectionAddress extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onChanged;
  final bool enabled;
  const SectionAddress(
      {super.key,
      required this.profile,
      required this.onChanged,
      this.enabled = true});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfileTextField(
            label: 'Alamat Lengkap',
            value: profile.address,
            hint: 'Masukkan Alamat',
            onChanged: onChanged,
            maxLength: 255,
            enabled: enabled,
            requiredField: true,
            validator: (value) => isValidProfileAddress(value ?? '')
                ? null
                : 'Alamat harus 1–255 karakter',
            lines: 4)
      ]);
}

class SectionBusinessLogo extends StatelessWidget {
  final SettingProfile profile;
  final VoidCallback onUpload;
  final bool enabled;
  final BusinessLogoStatus logoStatus;
  const SectionBusinessLogo(
      {super.key,
      required this.profile,
      required this.onUpload,
      this.enabled = true,
      this.logoStatus = BusinessLogoStatus.ready});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(children: [
              ClipOval(
                  child: SizedBox(
                      width: 48, height: 48, child: _logoImage(profile))),
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

  Widget _logoImage(SettingProfile profile) {
    if (logoStatus == BusinessLogoStatus.awaitingRefresh) {
      return _logoSpinner();
    }
    if (logoStatus == BusinessLogoStatus.refreshFailed) {
      return const Icon(Icons.broken_image_outlined);
    }
    if (profile.logoPath != null) {
      return Image.file(File(profile.logoPath!), fit: BoxFit.cover);
    }
    final url = profile.logoUrl;
    if (url == null) {
      return SvgPicture.asset('assets/images/superapp/home/ic_komerce_os.svg');
    }
    return Image.network(url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _logoSpinner(),
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined));
  }

  Widget _logoSpinner() => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBase,
          ),
        ),
      );
}

class SectionBusinessInfo extends StatelessWidget {
  final SettingProfile profile;
  final ValueChanged<String> onNameChanged, onPhoneChanged;
  final VoidCallback onLocationTap, onSectorTap;
  final bool enabled;
  final bool showRequiredErrors;
  const SectionBusinessInfo(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      required this.onPhoneChanged,
      required this.onLocationTap,
      required this.onSectorTap,
      this.enabled = true,
      this.showRequiredErrors = false});
  @override
  Widget build(BuildContext context) => ProfileFormCard(children: [
        ProfileTextField(
            label: 'Nama Bisnis',
            value: profile.businessName,
            hint: 'Nama Bisnis',
            onChanged: onNameChanged,
            requiredField: true,
            emptyErrorText: 'Nama Bisnis harus diisi',
            maxLength: 30),
        ProfileTextField(
            label: 'No. HP Bisnis',
            value: profile.businessPhone,
            hint: 'No HP Bisnis',
            onChanged: onPhoneChanged,
            requiredField: true,
            emptyErrorText: 'No. HP Bisnis harus diisi',
            phone: true),
        ProfilePickerField(
            label: 'Lokasi',
            value: profile.location?.label,
            hint: 'Masukkan Lokasi',
            onTap: onLocationTap,
            requiredField: true,
            errorText: profile.location == null &&
                    (showRequiredErrors ||
                        profile.businessName.trim().isNotEmpty ||
                        profile.businessPhone.trim().isNotEmpty)
                ? 'Lokasi harus diisi'
                : null,
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
  final bool showRequiredErrors;
  final BusinessLogoStatus logoStatus;
  const SectionBusiness(
      {super.key,
      required this.profile,
      required this.onNameChanged,
      required this.onPhoneChanged,
      required this.onUpload,
      required this.onLocationTap,
      required this.onSectorTap,
      this.enabled = true,
      this.logoStatus = BusinessLogoStatus.ready,
      this.showRequiredErrors = false});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ProfileSectionHeading('Profile Bisnis'),
        SectionBusinessLogo(
            profile: profile,
            enabled: enabled,
            onUpload: onUpload,
            logoStatus: logoStatus),
        const SizedBox(height: AppSpacing.lg),
        SectionBusinessInfo(
            profile: profile,
            enabled: enabled,
            showRequiredErrors: showRequiredErrors,
            onNameChanged: onNameChanged,
            onPhoneChanged: onPhoneChanged,
            onLocationTap: onLocationTap,
            onSectorTap: onSectorTap),
      ]);
}
