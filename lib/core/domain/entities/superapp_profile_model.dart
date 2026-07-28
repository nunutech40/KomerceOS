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

  // Sub-data
  final List<ProductMailVerificationModel> productMailVerifications;
  final List<UserLevelModel> userLevels;

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
    this.productMailVerifications = const [],
    this.userLevels = const [],
  });

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
        productMailVerifications,
        userLevels,
      ];
}
