import 'package:equatable/equatable.dart';

class MetaResponse extends Equatable {
  final String? message;

  /// Backend uses numeric codes for most APIs but string codes for selected
  /// domain errors (for example `ERR_ROLE_TEAM_INTERNAL_BLOCKED`).
  final Object? code;
  final String? status;

  const MetaResponse(
      {required this.status, required this.code, required this.message});

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "message": message,
      };

  factory MetaResponse.fromJson(Map<String, dynamic> json) {
    return MetaResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  List<Object?> get props => [
        status,
        code,
        message,
      ];
}
