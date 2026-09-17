import 'package:equatable/equatable.dart';
import '../domain/entities/setting_profile.dart';

class SettingProfileState extends Equatable {
  final SettingProfile original, draft;
  final bool loading,
      loadingLocations,
      loadingSectors,
      saving,
      savingAccount,
      savingBusiness,
      accountReadOnly;
  final List<ProfileOption> locations, businessSectors;
  final String? message;
  const SettingProfileState(
      {required this.original,
      required this.draft,
      this.loading = false,
      this.loadingLocations = false,
      this.loadingSectors = false,
      this.saving = false,
      this.savingAccount = false,
      this.savingBusiness = false,
      this.accountReadOnly = false,
      this.locations = const [],
      this.businessSectors = const [],
      this.message});
  const SettingProfileState.initial()
      : original = _uiPlaceholderProfile,
        draft = _uiPlaceholderProfile,
        loading = false,
        loadingLocations = false,
        loadingSectors = false,
        saving = false,
        savingAccount = false,
        savingBusiness = false,
        accountReadOnly = false,
        locations = const [],
        businessSectors = const [],
        message = null;
  bool get isDirty => draft != original;
  bool get canSave => isDirty && draft.isValid && !saving && !loading;
  SettingProfileState copyWith(
          {SettingProfile? original,
          SettingProfile? draft,
          bool? loading,
          bool? loadingLocations,
          bool? loadingSectors,
          bool? saving,
          bool? savingAccount,
          bool? savingBusiness,
          bool? accountReadOnly,
          List<ProfileOption>? locations,
          List<ProfileOption>? businessSectors,
          String? message}) =>
      SettingProfileState(
          original: original ?? this.original,
          draft: draft ?? this.draft,
          loading: loading ?? this.loading,
          loadingLocations: loadingLocations ?? this.loadingLocations,
          loadingSectors: loadingSectors ?? this.loadingSectors,
          saving: saving ?? this.saving,
          savingAccount: savingAccount ?? this.savingAccount,
          savingBusiness: savingBusiness ?? this.savingBusiness,
          accountReadOnly: accountReadOnly ?? this.accountReadOnly,
          locations: locations ?? this.locations,
          businessSectors: businessSectors ?? this.businessSectors,
          message: message);
  @override
  List<Object?> get props => [
        original,
        draft,
        loading,
        loadingLocations,
        loadingSectors,
        saving,
        savingAccount,
        savingBusiness,
        accountReadOnly,
        locations,
        businessSectors,
        message
      ];
}

/// Temporary presentation data used while the profile API is not wired yet.
const _uiPlaceholderProfile = SettingProfile(
  fullName: 'Rilas Test',
  username: 'rilastest22',
  phone: '087713222333',
  email: 'rilastest22@yopmail.com',
  address: 'Test Ya',
  gender: ProfileGender.male,
  businessName: '3D Printing',
  businessPhone: '08955559837',
  location: ProfileOption(id: 'placeholder-location', label: 'Teupah Selatan'),
  businessSector:
      ProfileOption(id: 'placeholder-sector', label: 'Perabotan Rumah'),
);
