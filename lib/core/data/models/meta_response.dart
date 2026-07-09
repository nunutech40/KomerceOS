import 'package:equatable/equatable.dart';

class MetaResponse extends Equatable {
  final String? message;
  final int? code;
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
