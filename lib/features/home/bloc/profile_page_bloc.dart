import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:bloc/bloc.dart';

import '../../../common/enum_status.dart';
import '../../../common/failure.dart';
import '../../../core/domain/entities/check_pin_model.dart';
import '../../../core/domain/entities/profile_model.dart';
import '../../../core/domain/usecases/check_pin_use_case.dart';
import '../../../core/domain/usecases/do_logout_use_case.dart';
import '../../../core/domain/usecases/get_profile_use_case.dart';

part 'profile_page_state.dart';
part 'profile_page_event.dart';

class ProfilePageBloc extends Bloc<ProfilePageEvent, ProfilePageState> {
  ProfilePageBloc(
      {required this.doLogoutUseCase,
      required this.getProfileUseCase,
      required this.checkPinUseCase})
      : super(const ProfilePageState()) {
    on<LogoutButtonPressedEvent>(_handleButtonLogout);
    on<ProfilePageDidload>(_handleDidLoadProfilePage);
    on<NextPressedButtonEvent>(_handleCheckPinExist);
  }

  final DoLogoutUseCase doLogoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final CheckPinUseCase checkPinUseCase;

  Future<void> _handleDidLoadProfilePage(
    ProfilePageDidload event,
    Emitter<ProfilePageState> emit,
  ) async {
    emit(
        state.copyWith(status: RequestStatus.loading, operation: 'getProfile'));
    // await Future.delayed(const Duration(seconds: 5));
    final profileResult = await getProfileUseCase.execute();

    profileResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (profileData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            profileData: profileData));
      },
    );
  }

  Future<void> _handleButtonLogout(
    LogoutButtonPressedEvent event,
    Emitter<ProfilePageState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
      operation: 'logoutState',
    ));

    final result = await doLogoutUseCase.execute();

    result.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (logoutData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
        )); // Reset profile data on logout
      },
    );
  }

  Future<void> _handleCheckPinExist(
    NextPressedButtonEvent event,
    Emitter<ProfilePageState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'checkPinExist'));

    final pinResult = await checkPinUseCase.execute();

    pinResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (pinData) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          pinData: pinData,
        ));
      },
    );
  }
}
