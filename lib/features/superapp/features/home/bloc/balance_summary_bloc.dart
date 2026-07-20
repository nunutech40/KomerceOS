import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/domain/entities/balance_summary_model.dart';
import '../../../../../core/domain/usecases/get_balance_summary_use_case.dart';

part 'balance_summary_event.dart';
part 'balance_summary_state.dart';

class BalanceSummaryBloc
    extends Bloc<BalanceSummaryEvent, BalanceSummaryState> {
  final GetBalanceSummaryUseCase getBalanceSummaryUseCase;

  BalanceSummaryBloc({required this.getBalanceSummaryUseCase})
      : super(BalanceSummaryInitial()) {
    on<FetchBalanceSummaryEvent>(_onFetch);
  }

  void _onFetch(
      FetchBalanceSummaryEvent event, Emitter<BalanceSummaryState> emit) async {
    emit(BalanceSummaryLoading());
    final result = await getBalanceSummaryUseCase.call(event.partnerId);
    result.fold(
      (failure) => emit(BalanceSummaryError(failure.message)),
      (data) => emit(BalanceSummaryLoaded(data)),
    );
  }
}
