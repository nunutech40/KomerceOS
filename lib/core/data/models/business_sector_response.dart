import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';

/// Data model (JSON) untuk satu item business sector dari API.
/// Endpoint: GET /talent-pool/api/v1/resource/business_sector
class BusinessSectorResponse extends Equatable {
  final int? id;
  final String? partnerCategoryName;
  final bool? status;
  final String? createdAt;
  final String? updatedAt;

  const BusinessSectorResponse({
    this.id,
    this.partnerCategoryName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessSectorResponse.fromJson(Map<String, dynamic> json) {
    return BusinessSectorResponse(
      id: json['id'],
      partnerCategoryName: json['partner_category_name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'partner_category_name': partnerCategoryName,
        'status': status,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  BusinessSectorModel toEntity() {
    return BusinessSectorModel(
      id: id,
      partnerCategoryName: partnerCategoryName,
      status: status,
    );
  }

  @override
  List<Object?> get props => [id, partnerCategoryName, status, createdAt, updatedAt];
}
