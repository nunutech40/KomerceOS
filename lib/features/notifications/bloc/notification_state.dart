part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  const NotificationState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.operation = '',
      this.notificationData});

  final String message;
  final RequestStatus status;
  final String operation;
  final List<NotificationsDataModel>? notificationData;

  NotificationState copyWith({
    RequestStatus? status,
    String? message,
    String? operation,
    List<NotificationsDataModel>? notificationData,
  }) {
    return NotificationState(
        status: status ?? this.status,
        message: message ?? this.message,
        operation: operation ?? this.operation,
        notificationData: notificationData ?? this.notificationData);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
        notificationData,
      ];
}
