import 'package:equatable/equatable.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_notif_read_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_notifications_use_case.dart';

import '../../../common/enum_status.dart';
import '../../../common/failure.dart';

part 'notification_state.dart';
part 'notification_event.dart';

class NotificationBloc extends Bloc<NoitificationEvent, NotificationState> {
  NotificationBloc(
      {required this.getNotificationsUseCase,
      required this.getNotifReadUseCase})
      : super(const NotificationState()) {
    on<NotificationDataLoad>(_handleLoadDataNotifications);
    on<RefreshDataEvent>(_refresStateAndEvent);
    on<GetNotificationReadEvent>(_handleNotificationRead);
  }

  final GetNotificationsUseCase getNotificationsUseCase;
  final GetNotifReadUseCase getNotifReadUseCase;

  Future<void> _refresStateAndEvent(
    RefreshDataEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationState());
  }

  Future<void> _handleLoadDataNotifications(
    NotificationDataLoad event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: RequestStatus.loading));

    final notificationResult = await getNotificationsUseCase.execute();

    notificationResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (notificationData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          notificationData: notificationData,
        ));
      },
    );
  }

  Future<void> _handleNotificationRead(
    GetNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final feedDetailResult = await getNotifReadUseCase.execute(event.id);

    feedDetailResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (data) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        ));
      },
    );
  }
}
