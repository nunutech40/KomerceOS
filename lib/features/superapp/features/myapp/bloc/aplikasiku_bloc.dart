import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/aplikasiku_entity.dart';
import '../domain/usecases/get_aplikasiku_list_usecase.dart';
import 'package:komtim_partner/core/domain/usecases/resend_verification_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_locale_profile_use_case.dart';

part 'aplikasiku_event.dart';
part 'aplikasiku_state.dart';

class AplikasikuBloc extends Bloc<AplikasikuEvent, AplikasikuState> {
  final GetAplikasikuListUseCase getAplikasikuListUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final GetLocaleProfileUseCase getLocaleProfileUseCase;

  AplikasikuBloc({
    required this.getAplikasikuListUseCase,
    required this.resendVerificationUseCase,
    required this.getLocaleProfileUseCase,
  }) : super(AplikasikuInitial()) {
    on<FetchAplikasikuEvent>(_onFetchAplikasiku);
    on<ResendVerificationAplikasiEvent>(_onResendVerification);
  }

  void _onFetchAplikasiku(FetchAplikasikuEvent event, Emitter<AplikasikuState> emit) async {
    emit(AplikasikuLoading());
    final result = await getAplikasikuListUseCase.call();
    result.fold(
      (failure) => emit(AplikasikuError(failure.message)),
      (data) => emit(AplikasikuLoaded(data)),
    );
  }

  void _onResendVerification(ResendVerificationAplikasiEvent event, Emitter<AplikasikuState> emit) async {
    final currentState = state;
    if (currentState is! AplikasikuLoaded) return;

    // Show loading for resend
    emit(currentState.copyWith(isResending: true, resendMessage: null, resendCountDown: null));

    // Get email from local profile
    final profileResult = await getLocaleProfileUseCase.execute();
    String? email;
    profileResult.fold(
      (failure) => null,
      (profile) => email = profile.email,
    );

    if (email == null || email!.isEmpty) {
      emit(currentState.copyWith(isResending: false, resendMessage: 'Email tidak ditemukan'));
      return;
    }

    final result = await resendVerificationUseCase.execute(email!, event.productName);

    result.fold(
      (failure) {
        final countDown = _parseCountDown(failure.message);
        emit(currentState.copyWith(
          isResending: false,
          resendMessage: failure.message,
          resendCountDown: countDown > 0 ? countDown : null,
        ));
      },
      (_) => emit(currentState.copyWith(
        isResending: false,
        resendMessage: 'Email verifikasi berhasil dikirim',
        resendCountDown: null,
      )),
    );
  }

  int _parseCountDown(String message) {
    final match = RegExp(r'count_down:\s*(\d+)').firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }
}
