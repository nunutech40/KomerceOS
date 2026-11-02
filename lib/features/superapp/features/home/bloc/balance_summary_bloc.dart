import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/failure.dart';
import '../../../../../core/domain/entities/balance_summary_model.dart';
import '../../../../../core/domain/usecases/get_balance_summary_use_case.dart';

part 'balance_summary_event.dart';
part 'balance_summary_state.dart';

class BalanceSummaryBloc
    extends Bloc<BalanceSummaryEvent, BalanceSummaryState> {
  final GetBalanceSummaryUseCase getBalanceSummaryUseCase;
  String? _loadingPartnerId;
  int _requestVersion = 0;

  BalanceSummaryBloc({required this.getBalanceSummaryUseCase})
      : super(BalanceSummaryInitial()) {
    on<FetchBalanceSummaryEvent>(_onFetch);
  }

  Future<void> _onFetch(
      FetchBalanceSummaryEvent event, Emitter<BalanceSummaryState> emit) async {
    if (_loadingPartnerId == event.partnerId) return;
    _loadingPartnerId = event.partnerId;
    final requestVersion = ++_requestVersion;
    emit(BalanceSummaryLoading());
    try {
      final result = await getBalanceSummaryUseCase.call(event.partnerId);
      if (emit.isDone || requestVersion != _requestVersion) return;
      result.fold(
        (failure) => emit(BalanceSummaryError(failure)),
        (data) => emit(BalanceSummaryLoaded(data)),
      );
    } finally {
      if (requestVersion == _requestVersion) _loadingPartnerId = null;
    }
  }
}
