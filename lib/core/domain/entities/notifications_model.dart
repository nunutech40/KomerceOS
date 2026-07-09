import 'package:equatable/equatable.dart';

class NotificationsModel extends Equatable {
  List<NotificationsDataModel>? data;

  NotificationsModel({this.data});

  @override
  List<Object?> get props => [data];
}

class NotificationsDataModel extends Equatable {
  int? notificationId;
  int? notificationType;
  int? targetId;
  String? attachmentImageUrl;
  String? invoiceCode;
  String? title;
  String? message;
  int? isRead;
  String? createdAt;
  String? updatedAt;

  NotificationsDataModel(
      {this.notificationId,
      this.notificationType,
      this.targetId,
      this.attachmentImageUrl,
      this.invoiceCode,
      this.title,
      this.message,
      this.isRead,
      this.createdAt,
      this.updatedAt});

  @override
  List<Object?> get props => [
        notificationId,
        notificationType,
        targetId,
        attachmentImageUrl,
        invoiceCode,
        title,
        message,
        isRead,
        createdAt,
        updatedAt,
      ];
}
