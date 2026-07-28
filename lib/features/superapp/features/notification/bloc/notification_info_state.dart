part of 'notification_info_bloc.dart';

abstract class NotificationInfoState extends Equatable {
  const NotificationInfoState();

  @override
  List<Object?> get props => [];
}

class NotificationInfoInitial extends NotificationInfoState {}

class NotificationInfoLoading extends NotificationInfoState {}

class NotificationInfoLoaded extends NotificationInfoState {
  final NotificationInfoModel data;

  const NotificationInfoLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class NotificationInfoError extends NotificationInfoState {
  final String message;

  const NotificationInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
