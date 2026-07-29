import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_v2_model.dart';

class NotificationV2GroupResponse extends Equatable {
  final String? dateGroup;
  final List<NotificationV2ItemResponse>? data;

  const NotificationV2GroupResponse({
    this.dateGroup,
    this.data,
  });

  factory NotificationV2GroupResponse.fromJson(Map<String, dynamic> json) {
    return NotificationV2GroupResponse(
      dateGroup: json['date_group'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => NotificationV2ItemResponse.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "date_group": dateGroup,
        "data": data?.map((e) => e.toJson()).toList(),
      };

  NotificationV2GroupModel toEntity() {
    return NotificationV2GroupModel(
      dateGroup: dateGroup,
      data: data?.map((e) => e.toEntity()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [dateGroup, data];
}

class NotificationV2ItemResponse extends Equatable {
  final int? id;
  final int? userTargetId;
  final int? partnerId;
  final String? title;
  final String? description;
  final int? isRead;
  final String? notificationType;
  final String? service;
  final String? imagePath;
  final int? referenceId;
  final String? logoPath;
  final String? createdAt;
  final String? updatedAt;

  const NotificationV2ItemResponse({
    this.id,
    this.userTargetId,
    this.partnerId,
    this.title,
    this.description,
    this.isRead,
    this.notificationType,
    this.service,
    this.imagePath,
    this.referenceId,
    this.logoPath,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationV2ItemResponse.fromJson(Map<String, dynamic> json) {
    return NotificationV2ItemResponse(
      id: json['id'],
      userTargetId: json['user_target_id'],
      partnerId: json['partner_id'],
      title: json['title'],
      description: json['description'],
      isRead: json['is_read'],
      notificationType: json['notification_type'],
      service: json['service'],
      imagePath: json['image_path'],
      referenceId: json['reference_id'],
      logoPath: json['logo_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_target_id": userTargetId,
        "partner_id": partnerId,
        "title": title,
        "description": description,
        "is_read": isRead,
        "notification_type": notificationType,
        "service": service,
        "image_path": imagePath,
        "reference_id": referenceId,
        "logo_path": logoPath,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  NotificationV2ItemModel toEntity() {
    return NotificationV2ItemModel(
      id: id,
      userTargetId: userTargetId,
      partnerId: partnerId,
      title: title,
      description: description,
      isRead: isRead,
      notificationType: notificationType,
      service: service,
      imagePath: imagePath,
      referenceId: referenceId,
      logoPath: logoPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userTargetId,
        partnerId,
        title,
        description,
        isRead,
        notificationType,
        service,
        imagePath,
        referenceId,
        logoPath,
        createdAt,
        updatedAt,
      ];
}
