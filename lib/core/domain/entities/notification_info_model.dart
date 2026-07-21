import 'package:equatable/equatable.dart';

class NotificationInfoModel extends Equatable {
  final int unreadCount;

  const NotificationInfoModel({required this.unreadCount});

  @override
  List<Object?> get props => [unreadCount];
}
