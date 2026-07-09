import 'package:equatable/equatable.dart';

class LoginModel extends Equatable {
  final String? accessToken;
  final String? tokenType;
  final UserLoginModel? data;

  const LoginModel({
    required this.accessToken,
    required this.tokenType,
    required this.data,
  });

  @override
  List<Object?> get props => [accessToken, tokenType, data];
}

class UserLoginModel extends Equatable {
  final int? id;
  final String? username;
  final String? fullName;
  final String? email;

  const UserLoginModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
  });

  @override
  List<Object?> get props => [id, username, fullName, email];
}

