import 'package:equatable/equatable.dart';

import '../../domain/entities/login_model.dart';

class LoginResponse extends Equatable {
  final String? accessToken;
  final String? tokenType;
  final UserLoginData? data;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "data": data?.toJson(),
      };

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      data: json['data'] != null ? UserLoginData.fromJson(json['data']) : null,
    );
  }

  LoginModel toEntity() {
    return LoginModel(
      accessToken: accessToken,
      tokenType: tokenType,
      data: data?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [accessToken, tokenType, data];
}

class UserLoginData extends Equatable {
  final int? id;
  final String? username;
  final String? fullName;
  final String? email;

  const UserLoginData({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "full_name": fullName,
        "email": email,
      };

  factory UserLoginData.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }
    return UserLoginData(
      id: parseId(json['id']),
      username: json['username'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }

  UserLoginModel toEntity() {
    return UserLoginModel(
      id: id,
      username: username,
      fullName: fullName,
      email: email,
    );
  }

  @override
  List<Object?> get props => [id, username, fullName, email];
}
