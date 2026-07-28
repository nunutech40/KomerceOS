import 'package:equatable/equatable.dart';

import '../../domain/entities/superapp_profile_model.dart';

class UserLevelResponse extends Equatable {
  final String? level;
  final int? position;
  final String? product;

  const UserLevelResponse({this.level, this.position, this.product});

  factory UserLevelResponse.fromJson(Map<String, dynamic> json) {
    return UserLevelResponse(
      level: json['level'],
      position: json['position'],
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'position': position,
        'product': product,
      };

  UserLevelModel toEntity() {
    return UserLevelModel(level: level, position: position, product: product);
  }

  @override
  List<Object?> get props => [level, position, product];
}

class ProductMailVerificationResponse extends Equatable {
  final String? productName;
  final bool? isVerified;

  const ProductMailVerificationResponse({this.productName, this.isVerified});

  factory ProductMailVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ProductMailVerificationResponse(
      productName: json['product_name'],
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product_name': productName,
        'is_verified': isVerified,
      };

  ProductMailVerificationModel toEntity() {
    return ProductMailVerificationModel(
        productName: productName, isVerified: isVerified);
  }

  @override
  List<Object?> get props => [productName, isVerified];
}

class SuperappProfileResponse extends Equatable {
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
  final int? saldo;
  final int? kompoints;
  final int? isKomship;
  final int? isKompack;
  final int? isKomplace;
  final int? isAffiliate;
  final int? isKomcards;
  final int? isKomchat;
  final List<ProductMailVerificationResponse> productMailVerifications;
  final List<UserLevelResponse> userLevels;

  const SuperappProfileResponse({
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

  factory SuperappProfileResponse.fromJson(Map<String, dynamic> json) {
    return SuperappProfileResponse(
      id: json['id'],
      roleName: json['role_name'],
      username: json['username'],
      status: json['status'],
      email: json['email'],
      roleId: json['role_id'],
      fullName: json['full_name'],
      noHp: json['no_hp'],
      address: json['address'],
      photoProfileUrl: json['photo_profile_url'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      saldo: json['saldo'],
      kompoints: json['kompoints'],
      isKomship: json['is_komship'],
      isKompack: json['is_kompack'],
      isKomplace: json['is_komplace'],
      isAffiliate: json['is_affiliate'],
      isKomcards: json['is_komcards'],
      isKomchat: json['is_komchat'],
      productMailVerifications: (json['product_mail_verifications'] as List?)
              ?.map((e) =>
                  ProductMailVerificationResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userLevels: (json['user_levels'] as List?)
              ?.map((e) => UserLevelResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Untuk cache lokal — TIDAK menyimpan saldo (finansial)
  Map<String, dynamic> toJsonCache() => {
        'id': id,
        'role_name': roleName,
        'username': username,
        'status': status,
        'email': email,
        'role_id': roleId,
        'full_name': fullName,
        'no_hp': noHp,
        'address': address,
        'photo_profile_url': photoProfileUrl,
        'birth_date': birthDate,
        'gender': gender,
        // saldo & kompoints sengaja tidak di-cache
        'is_komship': isKomship,
        'is_kompack': isKompack,
        'is_komplace': isKomplace,
        'is_affiliate': isAffiliate,
        'is_komcards': isKomcards,
        'is_komchat': isKomchat,
        'product_mail_verifications':
            productMailVerifications.map((e) => e.toJson()).toList(),
        'user_levels': userLevels.map((e) => e.toJson()).toList(),
      };

  /// Parse dari cache lokal (saldo akan null — perlu di-fetch dari API)
  factory SuperappProfileResponse.fromJsonCache(Map<String, dynamic> json) {
    return SuperappProfileResponse(
      id: json['id'],
      roleName: json['role_name'],
      username: json['username'],
      status: json['status'],
      email: json['email'],
      roleId: json['role_id'],
      fullName: json['full_name'],
      noHp: json['no_hp'],
      address: json['address'],
      photoProfileUrl: json['photo_profile_url'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      saldo: null, // saldo tidak pernah di-cache
      kompoints: null,
      isKomship: json['is_komship'],
      isKompack: json['is_kompack'],
      isKomplace: json['is_komplace'],
      isAffiliate: json['is_affiliate'],
      isKomcards: json['is_komcards'],
      isKomchat: json['is_komchat'],
      productMailVerifications: (json['product_mail_verifications'] as List?)
              ?.map((e) =>
                  ProductMailVerificationResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userLevels: (json['user_levels'] as List?)
              ?.map((e) => UserLevelResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  SuperappProfileModel toEntity() {
    return SuperappProfileModel(
      id: id,
      roleName: roleName,
      username: username,
      status: status,
      email: email,
      roleId: roleId,
      fullName: fullName,
      noHp: noHp,
      address: address,
      photoProfileUrl: photoProfileUrl,
      birthDate: birthDate,
      gender: gender,
      saldo: saldo,
      kompoints: kompoints,
      isKomship: isKomship,
      isKompack: isKompack,
      isKomplace: isKomplace,
      isAffiliate: isAffiliate,
      isKomcards: isKomcards,
      isKomchat: isKomchat,
      productMailVerifications:
          productMailVerifications.map((e) => e.toEntity()).toList(),
      userLevels: userLevels.map((e) => e.toEntity()).toList(),
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
        productMailVerifications,
        userLevels,
      ];
}
