import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';

class NotificationsResponse extends Equatable {
  final List<NotificationsResponseData>? data;

  const NotificationsResponse({required this.data});

  Map<String, dynamic> toJson() => {
        "data": data?.map((item) => item.toJson()).toList(),
      };

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => NotificationsResponseData.fromJson(item))
          .toList(),
    );
  }

  NotificationsModel toEntity() {
    return NotificationsModel(
      data: data
          ?.map((item) => item.toEntity())
          .toList(), // Map each item to entity
    );
  }

  @override
  List<Object?> get props => [data];
}

class NotificationsResponseData extends Equatable {
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

  NotificationsResponseData(
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
  Map<String, dynamic> toJson() => {
        "notification_id": notificationId,
        "notification_type": notificationType,
        "target_id": targetId,
        "attachment_image_url": attachmentImageUrl,
        "invoice_code": invoiceCode,
        "title": title,
        "message": message,
        "is_read": isRead,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };

  factory NotificationsResponseData.fromJson(Map<String, dynamic> json) {
    return NotificationsResponseData(
      notificationId: json['notification_id'],
      notificationType: json["notification_type"],
      targetId: json["target_id"],
      attachmentImageUrl: json["attachment_image_url"],
      invoiceCode: json['invoice_code'],
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  NotificationsDataModel toEntity() {
    return NotificationsDataModel(
      notificationId: notificationId,
      notificationType: notificationType,
      targetId: targetId,
      attachmentImageUrl: attachmentImageUrl,
      invoiceCode: invoiceCode,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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
        updatedAt
      ];
}
