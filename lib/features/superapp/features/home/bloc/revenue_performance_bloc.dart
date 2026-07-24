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

    // Generate default date (bulan ini) jika tidak disediakan UI
    final now = DateTime.now();
    final defaultStartDate = DateTime(now.year, now.month, 1);
    final defaultEndDate = DateTime(now.year, now.month + 1, 0);
    String format(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final startDate = event.startDate ?? format(defaultStartDate);
    final endDate = event.endDate ?? format(defaultEndDate);

    final result = await getRevenuePerformanceUseCase.call(
      startDate: startDate,
      endDate: endDate,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) => emit(RevenuePerformanceError(failure.message)),
      (data) => emit(RevenuePerformanceLoaded(data)),
    );
  }
}
