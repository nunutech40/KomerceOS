import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';

final RegExp _phoneNumberPattern = RegExp(r'^\+?[0-9]{8,15}$');

/// API menerima nomor 8–15 digit, dengan awalan `+` opsional.
bool isValidPhoneNumber(String value) =>
    _phoneNumberPattern.hasMatch(value.trim());

/// Hapus pemisah yang sering terbawa dari paste, tanpa mengubah 08… atau +62….
String normalizePhoneNumber(String value) {
  final trimmed = value.trim();
  final hasLeadingPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  return hasLeadingPlus ? '+$digits' : digits;
}

enum ProfileGender { male, female }

extension ProfileGenderLabel on ProfileGender {
  String get label => this == ProfileGender.male ? 'Laki-laki' : 'Perempuan';
}

/// API adapters own server IDs and gender mapping; widgets use typed values.
class ProfileOption extends Equatable {
  final String id;
  final String label;
  const ProfileOption({required this.id, required this.label});
  @override
  List<Object?> get props => [id, label];
}

class SettingProfile extends Equatable {
  final String fullName, username, phone, email, address;
  final String businessName, businessPhone;
  final ProfileGender? gender;
  final ProfileOption? location, businessSector;
  final String? logoUrl, logoPath;

  const SettingProfile({
    this.fullName = '',
    this.username = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.businessName = '',
    this.businessPhone = '',
    this.gender,
    this.location,
    this.businessSector,
    this.logoUrl,
    this.logoPath,
  });

  factory SettingProfile.fromGlobalProfile(SuperappProfileModel profile) {
    final business = profile.businessProfile;
    ProfileOption? option(String? label) => label == null || label.isEmpty
        ? null
        : ProfileOption(id: label, label: label);
    return SettingProfile(
      fullName: profile.fullName ?? '',
      username: profile.username ?? '',
      phone: profile.noHp ?? '',
      email: profile.email ?? '',
      address: profile.address ?? '',
      gender: switch (profile.gender) {
        1 => ProfileGender.male,
        2 => ProfileGender.female,
        _ => null,
      },
      businessName: business?.brandName ?? '',
      businessPhone: business?.businessPhone ?? '',
      location: option(business?.location),
      businessSector: option(business?.businessSector),
      logoUrl: business?.businessLogo,
    );
  }

  SettingProfile withAccountFrom(SettingProfile account) => SettingProfile(
        fullName: account.fullName,
        username: account.username,
        phone: account.phone,
        email: account.email,
        address: account.address,
        gender: account.gender,
        businessName: businessName,
        businessPhone: businessPhone,
        location: location,
        businessSector: businessSector,
        logoUrl: logoUrl,
        logoPath: logoPath,
      );

  SettingProfile withBusinessFrom(SettingProfile business) =>
      business.withAccountFrom(this);

  SettingProfile withoutSelectedLogo() => SettingProfile(
        fullName: fullName,
        username: username,
        phone: phone,
        email: email,
        address: address,
        businessName: businessName,
        businessPhone: businessPhone,
        gender: gender,
        location: location,
        businessSector: businessSector,
        logoUrl: logoUrl,
      );

  /// Keep edited fields while synchronizing untouched fields from global state.
  SettingProfile mergeRefresh(SettingProfile fresh, SettingProfile baseline) {
    T merge<T>(T current, T previous, T incoming) =>
        current == previous ? incoming : current;
    return SettingProfile(
      fullName: merge(fullName, baseline.fullName, fresh.fullName),
      username: merge(username, baseline.username, fresh.username),
      phone: merge(phone, baseline.phone, fresh.phone),
      email: merge(email, baseline.email, fresh.email),
      address: merge(address, baseline.address, fresh.address),
      gender: merge(gender, baseline.gender, fresh.gender),
      businessName:
          merge(businessName, baseline.businessName, fresh.businessName),
      businessPhone:
          merge(businessPhone, baseline.businessPhone, fresh.businessPhone),
      location: merge(location, baseline.location, fresh.location),
      businessSector:
          merge(businessSector, baseline.businessSector, fresh.businessSector),
      logoUrl: fresh.logoUrl,
      logoPath: merge(logoPath, baseline.logoPath, fresh.logoPath),
    );
  }

  SettingProfile copyWith({
    String? fullName,
    String? username,
    String? phone,
    String? email,
    String? address,
    String? businessName,
    String? businessPhone,
    ProfileGender? gender,
    ProfileOption? location,
    ProfileOption? businessSector,
    String? logoUrl,
    String? logoPath,
  }) =>
      SettingProfile(
        fullName: fullName ?? this.fullName,
        username: username ?? this.username,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        businessName: businessName ?? this.businessName,
        businessPhone: businessPhone ?? this.businessPhone,
        gender: gender ?? this.gender,
        location: location ?? this.location,
        businessSector: businessSector ?? this.businessSector,
        logoUrl: logoUrl ?? this.logoUrl,
        logoPath: logoPath ?? this.logoPath,
      );

  bool get isAccountValid =>
      fullName.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      isValidPhoneNumber(phone);

  bool get isBusinessValid =>
      businessName.trim().isNotEmpty &&
      businessName.length <= 30 &&
      isValidPhoneNumber(businessPhone) &&
      location != null;

  bool get isValid => isAccountValid && isBusinessValid;

  @override
  List<Object?> get props => [
        fullName,
        username,
        phone,
        email,
        address,
        businessName,
        businessPhone,
        gender,
        location,
        businessSector,
        logoUrl,
        logoPath
      ];
}
