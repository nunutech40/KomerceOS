import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komtim_partner/core/domain/entities/notification_info_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_notification_info_use_case.dart';

part 'notification_info_event.dart';
part 'notification_info_state.dart';

class NotificationInfoBloc extends Bloc<NotificationInfoEvent, NotificationInfoState> {
  final GetNotificationInfoUseCase getNotificationInfoUseCase;

  NotificationInfoBloc({required this.getNotificationInfoUseCase}) : super(NotificationInfoInitial()) {
    on<FetchNotificationInfoEvent>(_onFetchNotificationInfo);
  }

  Future<void> _onFetchNotificationInfo(
    FetchNotificationInfoEvent event,
    Emitter<NotificationInfoState> emit,
  ) async {
    emit(NotificationInfoLoading());

    final result = await getNotificationInfoUseCase();

    result.fold(
      (failure) => emit(NotificationInfoError(failure.message)),
      (data) => emit(NotificationInfoLoaded(data)),
    );
  }
}
