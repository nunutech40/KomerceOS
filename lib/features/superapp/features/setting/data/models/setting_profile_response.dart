import '../../domain/entities/setting_profile.dart';

class SettingProfileResponse {
  final String fullName;
  final String username;
  final String phone;
  final String email;
  final String address;
  final String? gender;
  final String businessName;
  final String businessPhone;
  final String? cityCode;
  final String? businessLocation;
  final String? businessSectorId;
  final String? businessSectorName;
  final String? businessLogo;

  const SettingProfileResponse({
    required this.fullName,
    required this.username,
    required this.phone,
    required this.email,
    required this.address,
    this.gender,
    required this.businessName,
    required this.businessPhone,
    this.cityCode,
    this.businessLocation,
    this.businessSectorId,
    this.businessSectorName,
    this.businessLogo,
  });

  factory SettingProfileResponse.fromJson(Map<String, dynamic> json) =>
      SettingProfileResponse(
        fullName: '${json['user_fullname'] ?? json['full_name'] ?? ''}',
        username: '${json['user_name'] ?? json['username'] ?? ''}',
        phone: '${json['user_phone'] ?? json['no_hp'] ?? ''}',
        email: '${json['user_email'] ?? json['email'] ?? ''}',
        address: '${json['user_address'] ?? json['address'] ?? ''}',
        gender: json['user_gender']?.toString() ?? json['gender']?.toString(),
        businessName: '${json['partner_business_name'] ?? ''}',
        businessPhone: '${json['partner_no_hp_business'] ?? ''}',
        cityCode: json['city_code']?.toString(),
        businessLocation: json['address_partner_business']?.toString(),
        businessSectorId: json['partner_category_id']?.toString(),
        businessSectorName: json['partner_category_name']?.toString(),
        businessLogo: json['partner_business_logo']?.toString(),
      );

  SettingProfile toEntity() {
    ProfileOption? option(String? id, String? label) =>
        label == null || label.isEmpty
            ? null
            : ProfileOption(id: id ?? label, label: label);
    final normalizedGender = gender?.toLowerCase();
    return SettingProfile(
      fullName: fullName,
      username: username,
      phone: phone,
      email: email,
      address: address,
      gender: normalizedGender == '1' ||
              normalizedGender == 'male' ||
              normalizedGender == 'laki-laki'
          ? ProfileGender.male
          : normalizedGender == '2' ||
                  normalizedGender == 'female' ||
                  normalizedGender == 'perempuan'
              ? ProfileGender.female
              : null,
      businessName: businessName,
      businessPhone: businessPhone,
      location: option(cityCode, businessLocation),
      businessSector: option(businessSectorId, businessSectorName),
      logoUrl: businessLogo,
    );
  }
}

class BusinessSectorResponse {
  final String id;
  final String name;
  const BusinessSectorResponse({required this.id, required this.name});
  factory BusinessSectorResponse.fromJson(Map<String, dynamic> json) =>
      BusinessSectorResponse(
        id: '${json['id'] ?? json['partner_category_name'] ?? ''}',
        name: '${json['partner_category_name'] ?? ''}',
      );
  ProfileOption toEntity() => ProfileOption(id: id, label: name);
}

class BusinessLocationResponse {
  final String cityCode;
  final String name;
  const BusinessLocationResponse({required this.cityCode, required this.name});
  factory BusinessLocationResponse.fromJson(Map<String, dynamic> json) =>
      BusinessLocationResponse(
        cityCode: '${json['city_code'] ?? json['values'] ?? ''}',
        name: '${json['values'] ?? ''}',
      );
  ProfileOption toEntity() => ProfileOption(id: cityCode, label: name);
}
