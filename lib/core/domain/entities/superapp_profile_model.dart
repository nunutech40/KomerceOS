import 'package:equatable/equatable.dart';

class UserLevelModel extends Equatable {
  final String? level;
  final int? position;
  final String? product;

  const UserLevelModel({this.level, this.position, this.product});

  @override
  List<Object?> get props => [level, position, product];
}

class ProductMailVerificationModel extends Equatable {
  final String? productName;
  final bool? isVerified;

  const ProductMailVerificationModel({this.productName, this.isVerified});

  @override
  List<Object?> get props => [productName, isVerified];
}

class BusinessProfileModel extends Equatable {
  final String? businessLogo;
  final String? brandName;
  final String? location;
  final String? businessPhone;
  final String? businessSector;

  const BusinessProfileModel({
    this.businessLogo,
    this.brandName,
    this.location,
    this.businessPhone,
    this.businessSector,
  });

  @override
  List<Object?> get props => [
        businessLogo,
        brandName,
        location,
        businessPhone,
        businessSector,
      ];
}

/// Entity profile untuk Superapp (dari endpoint /api/v1/user/partner/get-profile-mobile)
/// Balance (saldo) TIDAK di-cache — selalu fresh dari API.
/// Data statis (nama, foto, email) di-cache lokal via SharedPref.
class SuperappProfileModel extends Equatable {
  final int? id;
  final String? roleName;
  final String? username;
  final int? status;
  final String? email;
  final int? roleId;
  final String? fullName;
  final String? noHp;
  final String? address;
  final String? photoProfileUrl;
  final String? birthDate;
  final int? gender;

  // Finansial — tidak di-cache, selalu dari API
  final int? saldo;
  final int? kompoints;

  // Product flags
  final int? isKomship;
  final int? isKompack;
  final int? isKomplace;
  final int? isAffiliate;
  final int? isKomcards;
  final int? isKomchat;
  final int? isKomtim;
  final String? accountStatus;
  final bool? isKtpVerified;
  final int? verificationKtpStatus;

  // Sub-data
  final List<ProductMailVerificationModel> productMailVerifications;
  final List<UserLevelModel> userLevels;
  final BusinessProfileModel? businessProfile;

  const SuperappProfileModel({
    this.id,
    this.roleName,
    this.username,
    this.status,
    this.email,
    this.roleId,
    this.fullName,
    this.noHp,
    this.address,
    this.photoProfileUrl,
    this.birthDate,
    this.gender,
    this.saldo,
    this.kompoints,
    this.isKomship,
    this.isKompack,
    this.isKomplace,
    this.isAffiliate,
    this.isKomcards,
    this.isKomchat,
    this.isKomtim,
    this.accountStatus,
    this.isKtpVerified,
    this.verificationKtpStatus,
    this.productMailVerifications = const [],
    this.userLevels = const [],
    this.businessProfile,
  });

  /// Avatar pada Home dan Pengaturan menampilkan logo bisnis jika tersedia.
  String? get displayLogoUrl {
    final businessLogo = businessProfile?.businessLogo?.trim();
    if (businessLogo != null &&
        businessLogo.isNotEmpty &&
        businessLogo != 'null' &&
        businessLogo != '-') {
      return businessLogo;
    }
    final profilePhoto = photoProfileUrl?.trim();
    if (profilePhoto == null ||
        profilePhoto.isEmpty ||
        profilePhoto == 'null' ||
        profilePhoto == '-') {
      return null;
    }
    return profilePhoto;
  }

  SuperappProfileModel copyWith({
    int? id,
    String? roleName,
    String? username,
    int? status,
    String? email,
    int? roleId,
    String? fullName,
    String? noHp,
    String? address,
    String? photoProfileUrl,
    String? birthDate,
    int? gender,
    int? saldo,
    int? kompoints,
    int? isKomship,
    int? isKompack,
    int? isKomplace,
    int? isAffiliate,
    int? isKomcards,
    int? isKomchat,
    int? isKomtim,
    String? accountStatus,
    bool? isKtpVerified,
    int? verificationKtpStatus,
    List<ProductMailVerificationModel>? productMailVerifications,
    List<UserLevelModel>? userLevels,
    BusinessProfileModel? businessProfile,
  }) {
    return SuperappProfileModel(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      username: username ?? this.username,
      status: status ?? this.status,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      fullName: fullName ?? this.fullName,
      noHp: noHp ?? this.noHp,
      address: address ?? this.address,
      photoProfileUrl: photoProfileUrl ?? this.photoProfileUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      saldo: saldo ?? this.saldo,
      kompoints: kompoints ?? this.kompoints,
      isKomship: isKomship ?? this.isKomship,
      isKompack: isKompack ?? this.isKompack,
      isKomplace: isKomplace ?? this.isKomplace,
      isAffiliate: isAffiliate ?? this.isAffiliate,
      isKomcards: isKomcards ?? this.isKomcards,
      isKomchat: isKomchat ?? this.isKomchat,
      isKomtim: isKomtim ?? this.isKomtim,
      accountStatus: accountStatus ?? this.accountStatus,
      isKtpVerified: isKtpVerified ?? this.isKtpVerified,
      verificationKtpStatus:
          verificationKtpStatus ?? this.verificationKtpStatus,
      productMailVerifications:
          productMailVerifications ?? this.productMailVerifications,
      userLevels: userLevels ?? this.userLevels,
      businessProfile: businessProfile ?? this.businessProfile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        roleName,
        username,
        status,
        email,
        roleId,
        fullName,
        noHp,
        address,
        photoProfileUrl,
        birthDate,
        gender,
        saldo,
        kompoints,
        isKomship,
        isKompack,
        isKomplace,
        isAffiliate,
        isKomcards,
        isKomchat,
        isKomtim,
        accountStatus,
        isKtpVerified,
        verificationKtpStatus,
        productMailVerifications,
        userLevels,
        businessProfile,
      ];
}
