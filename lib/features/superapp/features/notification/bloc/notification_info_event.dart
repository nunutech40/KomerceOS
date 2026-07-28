part of 'notification_info_bloc.dart';

abstract class NotificationInfoEvent extends Equatable {
  const NotificationInfoEvent();

  @override
  List<Object> get props => [];
}

class FetchNotificationInfoEvent extends NotificationInfoEvent {
  const FetchNotificationInfoEvent();
}
