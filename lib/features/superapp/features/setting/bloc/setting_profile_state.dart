import 'package:equatable/equatable.dart';
import '../domain/entities/setting_profile.dart';

enum BusinessLogoStatus { ready, awaitingRefresh, refreshFailed }

class SettingProfileState extends Equatable {
  final SettingProfile original, draft;
  final bool loading,
      loadingLocations,
      loadingSectors,
      saving,
      savingAccount,
      savingBusiness;
  final List<ProfileOption> locations, businessSectors;
  final BusinessLogoStatus logoStatus;
  final bool personalProfileVerified;
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
      this.locations = const [],
      this.businessSectors = const [],
      this.logoStatus = BusinessLogoStatus.ready,
      this.personalProfileVerified = false,
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
        locations = const [],
        businessSectors = const [],
        logoStatus = BusinessLogoStatus.ready,
        personalProfileVerified = false,
        message = null;
  // URL logo datang dari refresh server, bukan perubahan yang perlu disimpan.
  bool get isDirty => isAccountDirty || isBusinessDirty;
  bool get isAccountDirty =>
      !personalProfileVerified &&
      (original.fullName != draft.fullName ||
          original.gender != draft.gender ||
          original.address != draft.address);
  bool get isBusinessDirty =>
      original.businessName != draft.businessName ||
      original.businessPhone != draft.businessPhone ||
      original.location != draft.location ||
      original.businessSector != draft.businessSector ||
      original.logoPath != draft.logoPath;
  String? get saveValidationMessage {
    if (original.fullName != draft.fullName &&
        !isValidProfileName(draft.fullName)) {
      return 'Nama Lengkap harus 3–60 karakter dan hanya huruf.';
    }
    if (original.address != draft.address &&
        !isValidProfileAddress(draft.address)) {
      return 'Alamat Lengkap harus 1–255 karakter.';
    }
    // PUT bisnis mengirim semua field; jangan kirim data bisnis yang belum lengkap.
    if (isBusinessDirty) {
      if (draft.businessName.trim().isEmpty || draft.businessName.length > 30) {
        return 'Nama Bisnis harus 1–30 karakter.';
      }
      if (!isValidPhoneNumber(draft.businessPhone)) {
        return 'No. HP Bisnis harus 8–15 digit angka.';
      }
      if (draft.location == null) return 'Lokasi harus diisi.';
    }
    return null;
  }

  bool get canSave =>
      isDirty && saveValidationMessage == null && !saving && !loading;
  SettingProfileState copyWith(
          {SettingProfile? original,
          SettingProfile? draft,
          bool? loading,
          bool? loadingLocations,
          bool? loadingSectors,
          bool? saving,
          bool? savingAccount,
          bool? savingBusiness,
          List<ProfileOption>? locations,
          List<ProfileOption>? businessSectors,
          BusinessLogoStatus? logoStatus,
          bool? personalProfileVerified,
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
          locations: locations ?? this.locations,
          businessSectors: businessSectors ?? this.businessSectors,
          logoStatus: logoStatus ?? this.logoStatus,
          personalProfileVerified:
              personalProfileVerified ?? this.personalProfileVerified,
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
        locations,
        businessSectors,
        logoStatus,
        personalProfileVerified,
        message
      ];
}
