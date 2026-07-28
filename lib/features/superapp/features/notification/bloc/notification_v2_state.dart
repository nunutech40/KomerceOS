part of 'notification_v2_bloc.dart';

class NotificationV2State extends Equatable {
  final RequestStatus status;
  final String message;
  final List<NotificationV2GroupModel> data;
  final int offset;
  final bool hasReachedMax;
  final String filterStatus;
  final String filterService;

  const NotificationV2State({
    this.status = RequestStatus.empty,
    this.message = '',
    this.data = const [],
    this.offset = 0,
    this.hasReachedMax = false,
    this.filterStatus = 'semua', // semua, read, unread
    this.filterService = 'semua',
  });

  NotificationV2State copyWith({
    RequestStatus? status,
    String? message,
    List<NotificationV2GroupModel>? data,
    int? offset,
    bool? hasReachedMax,
    String? filterStatus,
    String? filterService,
  }) {
    return NotificationV2State(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      offset: offset ?? this.offset,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      filterStatus: filterStatus ?? this.filterStatus,
      filterService: filterService ?? this.filterService,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        data,
        offset,
        hasReachedMax,
        filterStatus,
        filterService,
      ];
}
