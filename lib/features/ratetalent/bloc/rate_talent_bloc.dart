import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_evaluation_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_talent_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/set_rating_talents_use_case.dart';

import '../../../core/domain/entities/talents_model.dart';

part 'rate_talent_event.dart';
part 'rate_talent_state.dart';

class RateTalentBloc extends Bloc<RateTalentEvent, RateTalentState> {
  RateTalentBloc(
      {required this.getTalensUseCase,
      required this.setRatingTalentsUseCase,
      required this.getTalentEvaluationsUseCase})
      : super(const RateTalentState()) {
    on<RateTalentPageDidload>(_handleDidLoadPage);
    on<SetTalentRateReq>(_handleSubmitRateTalents);
    on<RateTalentEvaluationPageDidload>(_handleDidLoadEvaluationPage);
    on<ResetRateTalentOperation>(_resetRateTalentOperation);
  }

  final GetTalensUseCase getTalensUseCase;
  final SetRatingTalentsUseCase setRatingTalentsUseCase;
  final GetTalentEvaluationsUseCase getTalentEvaluationsUseCase;

  Future<void> _handleDidLoadPage(
    RateTalentPageDidload event,
    Emitter<RateTalentState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'loadingTalents'));

    final talentsResult = await getTalensUseCase.execute();

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (talentsData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            talentsData: talentsData));
      },
    );
  }

  Future<void> _handleSubmitRateTalents(
    SetTalentRateReq event,
    Emitter<RateTalentState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'submittingRatings'));

    final setRateTalentResult = await setRatingTalentsUseCase.execute(
      event.talents,
      event.leaders,
      event.invoiceId,
      event.amount,
    );

    setRateTalentResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (setRating) {
        emit(state.copyWith(message: 'Success', status: RequestStatus.success));
      },
    );
  }

  Future<void> _handleDidLoadEvaluationPage(
    RateTalentEvaluationPageDidload event,
    Emitter<RateTalentState> emit,
  ) async {
    emit(state.copyWith(
        status: RequestStatus.loading, operation: 'loadingTalents'));

    final talentsResult =
        await getTalentEvaluationsUseCase.execute(invoiceId: event.invoiceId);

    talentsResult.fold(
      (failure) {
        emit(state.copyWith(
            message: failure.message, status: RequestStatus.failure));
      },
      (talentsData) {
        emit(state.copyWith(
            message: 'Success',
            status: RequestStatus.success,
            talentsData: talentsData));
      },
    );
  }

  void _resetRateTalentOperation(
    ResetRateTalentOperation event,
    Emitter<RateTalentState> emit,
  ) {
    emit(state.copyWith(
      operation: '',
      message: '',
    ));
  }
}
