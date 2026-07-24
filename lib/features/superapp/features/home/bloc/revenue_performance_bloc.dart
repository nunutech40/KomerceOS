import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/revenue_performance_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_revenue_performance_use_case.dart';


part 'revenue_performance_event.dart';
part 'revenue_performance_state.dart';

class RevenuePerformanceBloc
    extends Bloc<RevenuePerformanceEvent, RevenuePerformanceState> {
  final GetRevenuePerformanceUseCase getRevenuePerformanceUseCase;

  RevenuePerformanceBloc({required this.getRevenuePerformanceUseCase})
      : super(RevenuePerformanceInitial()) {
    on<FetchRevenuePerformanceEvent>(_onFetchRevenuePerformance);
  }

  void _onFetchRevenuePerformance(
    FetchRevenuePerformanceEvent event,
    Emitter<RevenuePerformanceState> emit,
  ) async {
    emit(RevenuePerformanceLoading());
    final result = await getRevenuePerformanceUseCase.call(
      startDate: event.startDate,
      endDate: event.endDate,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) => emit(RevenuePerformanceError(failure.message)),
      (data) => emit(RevenuePerformanceLoaded(data)),
    );
  }
}
