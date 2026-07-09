import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/basic_meta_data_model.dart';

class MetaResponses extends Equatable {
  final String? message;
  final int? code;
  final String? status;

  const MetaResponses({
    required this.status,
    required this.code,
    required this.message,
  });

  factory MetaResponses.fromJson(Map<String, dynamic> json) {
    return MetaResponses(
      status: json['status'],
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "message": message,
      };

  MetaModels toEntity() {
    return MetaModels(status: status, code: code, message: message);
  }

  @override
  List<Object?> get props => [status, code, message];
}

class BasicMetaDataResponse extends Equatable {
  final MetaResponses meta;
  final dynamic data;

  const BasicMetaDataResponse({
    required this.meta,
    required this.data,
  });

  factory BasicMetaDataResponse.fromJson(Map<String, dynamic> json) {
    return BasicMetaDataResponse(
      meta: MetaResponses.fromJson(json['meta']),
      data: json['data'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "meta": meta.toJson(),
        "data": data,
      };

  BasicMetaDataModels toEntity() {
    return BasicMetaDataModels(meta: meta.toEntity(), data: data);
  }

  @override
  List<Object?> get props => [meta, data];
}
