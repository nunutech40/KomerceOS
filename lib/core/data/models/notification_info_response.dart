import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_info_model.dart';

class NotificationInfoResponse extends Equatable {
  final int? unreadCount;

  const NotificationInfoResponse({this.unreadCount});

  factory NotificationInfoResponse.fromJson(Map<String, dynamic> json) {
    return NotificationInfoResponse(
      unreadCount: json['unread_count'],
    );
  }

  Map<String, dynamic> toJson() => {
        "unread_count": unreadCount,
      };

  NotificationInfoModel toEntity() {
    return NotificationInfoModel(
      unreadCount: unreadCount ?? 0,
    );
  }

  @override
  List<Object?> get props => [unreadCount];
}
