import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import '../data/services/profile_image_service.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../bloc/setting_profile_bloc.dart';
import '../bloc/setting_profile_event.dart';
import '../bloc/setting_profile_state.dart';
import '../domain/entities/setting_profile.dart';
import 'sections/profile_sections.dart';
import '../widget/profile_option_sheet.dart';

class SettingProfilePage extends StatefulWidget {
  const SettingProfilePage({super.key});

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  late final SettingProfileBloc _settingProfile;

  @override
  void initState() {
    super.initState();
    _settingProfile = locator<SettingProfileBloc>();
    final profile = context.read<SuperappProfileBloc>().state.displayProfile;
    if (profile != null) {
      _settingProfile.add(SettingProfileGlobalLoaded(profile));
    }
  }

  @override
  void dispose() {
    _settingProfile.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _settingProfile,
        child: BlocListener<SuperappProfileBloc, SuperappProfileState>(
          listenWhen: (previous, current) =>
              previous.displayProfile != current.displayProfile,
          listener: (_, state) {
            final profile = state.displayProfile;
            if (profile != null) {
              _settingProfile.add(SettingProfileGlobalLoaded(profile));
            }
          },
          child: _SettingProfileForm(config: widget),
        ),
      );
}

class _SettingProfileForm extends StatefulWidget {
  final SettingProfilePage config;
  const _SettingProfileForm({required this.config});
  @override
  State<_SettingProfileForm> createState() => _SettingProfileFormState();
}

class _SettingProfileFormState extends State<_SettingProfileForm> {
  final ProfileImageService _imageService = ProfileImageService();
  bool _selecting = false;
  SettingProfileBloc get settingProfile => context.read<SettingProfileBloc>();

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _select(
      String title,
      Future<List<ProfileOption>> Function() load,
      ProfileOption? current,
      void Function(ProfileOption) apply) async {
    if (_selecting) return;
    setState(() => _selecting = true);
    try {
      final options = await load();
      if (!mounted) return;
      final result = await showModalBottomSheet<ProfileOption>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ProfileOptionSheet(
              title: title,
              options: options,
              selectedId: current?.id,
              showSelectionIndicator: title == 'Jenis Kelamin'));
      if (mounted && result != null) apply(result);
    } catch (_) {
      if (mounted) _message('Gagal memuat pilihan. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  Future<void> _gender(SettingProfile profile) => _select(
      'Jenis Kelamin',
      () async => ProfileGender.values
          .map((e) => ProfileOption(id: e.name, label: e.label))
          .toList(),
      profile.gender == null
          ? null
          : ProfileOption(
              id: profile.gender!.name, label: profile.gender!.label),
      (value) => settingProfile.update(settingProfile.state.draft
          .copyWith(gender: ProfileGender.values.byName(value.id))));

  Future<void> _businessSector(SettingProfile profile) async {
    settingProfile.add(const SettingBusinessSectorsRequested());
    final result = await showModalBottomSheet<ProfileOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: settingProfile,
        child: BlocBuilder<SettingProfileBloc, SettingProfileState>(
          builder: (_, state) => ProfileOptionSheet(
            title: 'Sektor Bisnis',
            options: state.businessSectors,
            loading: state.loadingSectors,
            selectedId: profile.businessSector?.id,
          ),
        ),
      ),
    );
    if (mounted && result != null) {
      settingProfile
          .update(settingProfile.state.draft.copyWith(businessSector: result));
    }
  }

  Future<void> _businessLocation(SettingProfile profile) async {
    settingProfile.add(const SettingBusinessLocationsRequested(''));
    final result = await showModalBottomSheet<ProfileOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: settingProfile,
        child: BlocBuilder<SettingProfileBloc, SettingProfileState>(
          builder: (_, state) => ProfileOptionSheet(
            title: 'Masukkan Lokasi',
            options: state.locations,
            loading: state.loadingLocations,
            selectedId: profile.location?.id,
            searchable: true,
            onSearchChanged: (keyword) =>
                settingProfile.add(SettingBusinessLocationsRequested(keyword)),
          ),
        ),
      ),
    );
    if (mounted && result != null) {
      settingProfile
          .update(settingProfile.state.draft.copyWith(location: result));
    }
  }

  Future<void> _upload() async {
    setState(() => _selecting = true);
    try {
      final image = await _imageService.pickAndCompress();
      if (mounted && image != null) {
        settingProfile
            .update(settingProfile.state.draft.copyWith(logoPath: image.path));
      }
    } on FileSystemException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('Gagal memilih foto. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  void _contactInfo() {
    DsBottomSheet.show<void>(
        context: context,
        title: 'Informasi Akun',
        description:
            'Data ini hanya dapat diubah melalui Web Partner karena memerlukan verifikasi.',
        primaryButtonText: 'Buka Web Partner',
        onPrimaryPressed: () async {
          Navigator.pop(context);
          _message('Tautan Web Partner akan dihubungkan pada tahap integrasi.');
        });
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<SettingProfileBloc, SettingProfileState>(
        listener: (context, state) {
          if (state.message != null) _message(state.message!);
        },
        builder: (context, state) {
          final p = state.draft;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const DsAppBar(
                title: 'Profile',
                backgroundColor: AppColors.background,
                containerLeadingColor: AppColors.alwaysWhite),
            body: state.loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBase,
                    ),
                  )
                : AbsorbPointer(
                    absorbing: state.saving,
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionName(
                                  profile: p,
                                  readOnly: state.accountReadOnly,
                                  onNameChanged: (v) => settingProfile
                                      .update(p.copyWith(fullName: v)),
                                  onUsernameChanged: (v) => settingProfile
                                      .update(p.copyWith(username: v))),
                              const SizedBox(height: AppSpacing.lg),
                              SectionGender(
                                  profile: p,
                                  enabled:
                                      !state.accountReadOnly && !_selecting,
                                  onTap: () => _gender(p)),
                              const SizedBox(height: AppSpacing.lg),
                              SectionContacts(
                                  profile: p,
                                  readOnly: state.accountReadOnly,
                                  onTap: _contactInfo,
                                  onPhoneChanged: (v) => settingProfile
                                      .update(p.copyWith(phone: v)),
                                  onEmailChanged: (v) => settingProfile
                                      .update(p.copyWith(email: v))),
                              const SizedBox(height: AppSpacing.lg),
                              SectionAddress(
                                  profile: p,
                                  readOnly: state.accountReadOnly,
                                  onChanged: (v) => settingProfile
                                      .update(p.copyWith(address: v))),
                              const SizedBox(height: AppSpacing.xl),
                              SectionBusiness(
                                profile: p,
                                enabled: !_selecting,
                                onUpload: _upload,
                                onNameChanged: (v) => settingProfile
                                    .update(p.copyWith(businessName: v)),
                                onPhoneChanged: (v) => settingProfile
                                    .update(p.copyWith(businessPhone: v)),
                                onLocationTap: () => _businessLocation(p),
                                onSectorTap: () => _businessSector(p),
                              ),
                            ]))),
            bottomNavigationBar: ColoredBox(
                color: AppColors.alwaysWhite,
                child: SafeArea(
                    top: false,
                    child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: DsButton(
                            text: 'Simpan',
                            loadingText: 'Menyimpan...',
                            onPressed: settingProfile.save,
                            state: state.saving
                                ? DsButtonState.loading
                                : state.canSave && !_selecting
                                    ? DsButtonState.enabled
                                    : DsButtonState.disabled)))),
          );
        },
      );
}
