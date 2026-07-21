import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/domain/entities/notification_v2_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_notification_v2_list_use_case.dart';

part 'notification_v2_event.dart';
part 'notification_v2_state.dart';

class NotificationV2Bloc extends Bloc<NotificationV2Event, NotificationV2State> {
  final GetNotificationV2ListUseCase getNotificationV2ListUseCase;
  static const int _limit = 10;

  NotificationV2Bloc({required this.getNotificationV2ListUseCase})
      : super(const NotificationV2State()) {
    on<FetchNotificationV2Event>(_onFetchNotifications);
    on<FilterStatusChangedEvent>(_onFilterStatusChanged);
    on<FilterServiceChangedEvent>(_onFilterServiceChanged);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationV2Event event,
    Emitter<NotificationV2State> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefresh) return;

    if (state.status == RequestStatus.loading) return;

    if (event.isRefresh) {
      emit(state.copyWith(
        status: RequestStatus.loading,
        offset: 0,
        hasReachedMax: false,
      ));
    } else {
      if (state.offset == 0) {
        emit(state.copyWith(status: RequestStatus.loading));
      }
    }

    // Determine actual status query. API expects "read" or "unread", empty for all
    String statusQuery = '';
    if (state.filterStatus == 'read' || state.filterStatus == 'unread') {
      statusQuery = state.filterStatus;
    }

    final result = await getNotificationV2ListUseCase.call(
      state.offset,
      _limit,
      statusQuery,
      state.filterService,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: RequestStatus.failure,
          message: failure.message,
        ));
      },
      (data) {
        // Since data is grouped by date, we need to merge it properly if paginating
        // For simplicity with grouped data, we append the groups. If same date group exists, we merge inner data
        List<NotificationV2GroupModel> currentData = event.isRefresh ? [] : List.from(state.data);
        
        bool hasMoreData = false;
        
        for (var newGroup in data) {
          if (newGroup.data.isNotEmpty) {
            hasMoreData = true;
          }
          final index = currentData.indexWhere((g) => g.dateGroup == newGroup.dateGroup);
          if (index >= 0) {
            // Append to existing group
            final existingGroup = currentData[index];
            final mergedList = List<NotificationV2ItemModel>.from(existingGroup.data)..addAll(newGroup.data);
            currentData[index] = NotificationV2GroupModel(dateGroup: newGroup.dateGroup, data: mergedList);
          } else {
            // Add new group
            currentData.add(newGroup);
          }
        }

        // Count total items fetched to check if reached max
        int totalFetched = data.fold(0, (sum, group) => sum + group.data.length);
        
        emit(state.copyWith(
          status: RequestStatus.success,
          data: currentData,
          offset: state.offset + _limit,
          hasReachedMax: totalFetched < _limit || !hasMoreData,
        ));
      },
    );
  }

  void _onFilterStatusChanged(
    FilterStatusChangedEvent event,
    Emitter<NotificationV2State> emit,
  ) {
    if (state.filterStatus == event.status) return;
    emit(state.copyWith(filterStatus: event.status));
    add(const FetchNotificationV2Event(isRefresh: true));
  }

  void _onFilterServiceChanged(
    FilterServiceChangedEvent event,
    Emitter<NotificationV2State> emit,
  ) {
    if (state.filterService == event.service) return;
    emit(state.copyWith(filterService: event.service));
    add(const FetchNotificationV2Event(isRefresh: true));
  }
}
