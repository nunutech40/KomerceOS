import 'package:equatable/equatable.dart';

class NotificationV2GroupModel extends Equatable {
  final String? dateGroup;
  final List<NotificationV2ItemModel> data;

  const NotificationV2GroupModel({
    required this.dateGroup,
    required this.data,
  });

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
