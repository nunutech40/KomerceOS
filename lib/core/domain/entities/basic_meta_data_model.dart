import 'package:equatable/equatable.dart';

class MetaModels extends Equatable {
  final String? message;
  final int? code;
  final String? status;

  const MetaModels({
    required this.status,
    required this.code,
    required this.message,
  });

  @override
  List<Object?> get props => [status, code, message];
}

class BasicMetaDataModels extends Equatable {
  final MetaModels meta;
  final dynamic data;

  const BasicMetaDataModels({
    required this.meta,
    this.data,
  });

  @override
  List<Object?> get props => [meta, data];
}
