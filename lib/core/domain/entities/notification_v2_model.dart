import 'package:equatable/equatable.dart';

class NotificationV2GroupModel extends Equatable {
  final String? dateGroup;
  final List<NotificationV2ItemModel> data;

  const NotificationV2GroupModel({
    required this.dateGroup,
    required this.data,
  });

  NotificationV2GroupModel copyWith({
    String? dateGroup,
    List<NotificationV2ItemModel>? data,
  }) {
    return NotificationV2GroupModel(
      dateGroup: dateGroup ?? this.dateGroup,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [dateGroup, data];
}

class NotificationV2ItemModel extends Equatable {
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

  const NotificationV2ItemModel({
    required this.id,
    required this.userTargetId,
    required this.partnerId,
    required this.title,
    required this.description,
    required this.isRead,
    required this.notificationType,
    required this.service,
    required this.imagePath,
    required this.referenceId,
    required this.logoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  NotificationV2ItemModel copyWith({
    int? id,
    int? userTargetId,
    int? partnerId,
    String? title,
    String? description,
    int? isRead,
    String? notificationType,
    String? service,
    String? imagePath,
    int? referenceId,
    String? logoPath,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationV2ItemModel(
      id: id ?? this.id,
      userTargetId: userTargetId ?? this.userTargetId,
      partnerId: partnerId ?? this.partnerId,
      title: title ?? this.title,
      description: description ?? this.description,
      isRead: isRead ?? this.isRead,
      notificationType: notificationType ?? this.notificationType,
      service: service ?? this.service,
      imagePath: imagePath ?? this.imagePath,
      referenceId: referenceId ?? this.referenceId,
      logoPath: logoPath ?? this.logoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
