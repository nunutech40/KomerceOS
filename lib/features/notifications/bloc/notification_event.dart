part of 'notification_bloc.dart';

@immutable
abstract class NoitificationEvent extends Equatable {
  const NoitificationEvent();

  @override
  List<Object?> get props => [];
}

class RefreshDataEvent extends NoitificationEvent {
  const RefreshDataEvent();
}

class NotificationDataLoad extends NoitificationEvent {
  const NotificationDataLoad();
}

class GetNotificationReadEvent extends NoitificationEvent {
  final int id;

  const GetNotificationReadEvent({
    required this.id,
  });
  @override
  List<Object?> get props => [id];
}
