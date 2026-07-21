part of 'notification_v2_bloc.dart';

abstract class NotificationV2Event extends Equatable {
  const NotificationV2Event();

  @override
  List<Object?> get props => [];
}

class FetchNotificationV2Event extends NotificationV2Event {
  final bool isRefresh;
  
  const FetchNotificationV2Event({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterStatusChangedEvent extends NotificationV2Event {
  final String status;
  
  const FilterStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterServiceChangedEvent extends NotificationV2Event {
  final String service;
  
  const FilterServiceChangedEvent(this.service);

  @override
  List<Object?> get props => [service];
}
