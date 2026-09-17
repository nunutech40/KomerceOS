import 'package:equatable/equatable.dart';

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

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      businessName.trim().isNotEmpty &&
      businessName.length <= 30 &&
      RegExp(r'^\+?[0-9]{8,15}$').hasMatch(businessPhone.trim()) &&
      location != null;

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
