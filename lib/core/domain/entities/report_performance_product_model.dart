import 'package:equatable/equatable.dart';

class ReportPerformanceProductModel extends Equatable {
  final int? id;
  final String? name;

  const ReportPerformanceProductModel({
    this.id,
    this.name,
  });

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}
