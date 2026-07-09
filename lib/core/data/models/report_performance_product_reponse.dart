import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_product_model.dart';

class ReportPerformanceProductResponse extends Equatable {
  final int? id;
  final String? name;

  const ReportPerformanceProductResponse({
    this.id,
    this.name,
  });

  factory ReportPerformanceProductResponse.fromJson(Map<String, dynamic> json) {
    return ReportPerformanceProductResponse(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  ReportPerformanceProductModel toEntity() {
    return ReportPerformanceProductModel(
      id: id,
      name: name,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}
