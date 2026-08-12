import 'package:equatable/equatable.dart';

/// Entity domain untuk satu item Business Sector.
class BusinessSectorModel extends Equatable {
  final int? id;
  final String? partnerCategoryName;
  final bool? status;

  const BusinessSectorModel({
    this.id,
    this.partnerCategoryName,
    this.status,
  });

  @override
  List<Object?> get props => [id, partnerCategoryName, status];
}
