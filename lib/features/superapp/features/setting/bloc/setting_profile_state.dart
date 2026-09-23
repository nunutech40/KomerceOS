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
      : original = const SettingProfile(),
        draft = const SettingProfile(),
        loading = true,
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
  bool get isAccountDirty =>
      original.fullName != draft.fullName ||
      original.username != draft.username ||
      original.phone != draft.phone ||
      original.email != draft.email ||
      original.gender != draft.gender ||
      original.address != draft.address;
  bool get isBusinessDirty =>
      original.businessName != draft.businessName ||
      original.businessPhone != draft.businessPhone ||
      original.location != draft.location ||
      original.businessSector != draft.businessSector ||
      original.logoPath != draft.logoPath;
  bool get canSave =>
      isDirty &&
      (!isAccountDirty || (!accountReadOnly && draft.isAccountValid)) &&
      (!isBusinessDirty || draft.isBusinessValid) &&
      !saving &&
      !loading;
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
