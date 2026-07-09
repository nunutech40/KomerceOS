import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_monthly_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_product_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_weekly_use_case.dart';
import 'package:komtim_partner/features/performance/bloc/report_performance_event.dart';
import 'package:komtim_partner/features/performance/bloc/report_performance_state.dart';

class ReportPerformanceBloc
    extends Bloc<ReportPerformanceEvent, ReportPerformanceState> {
  ReportPerformanceBloc({
    required this.getReportPerformanceUseCase,
    required this.getReportPerformanceProductUseCase,
    required this.getReportPerformanceWeeklyUseCase,
    required this.getReportPerformanceMonthlyUseCase,
  }) : super(const ReportPerformanceState()) {
    on<GetReportPerformanceEvent>(_handleGetReportPerformance);
    on<GetReportPerformanceProductEvent>(_handleGetProductReportPerformance);
    on<GetReportPerformanceWeekEvent>(_handleGetWeeklyReportPerformance);
    on<GetReportPerformanceMonthEvent>(_handleGetMonthlyReportPerformance);
  }

  final GetReportPerformanceUseCase getReportPerformanceUseCase;
  final GetReportPerformanceProductUseCase getReportPerformanceProductUseCase;
  final GetReportPerformanceWeeklyUseCase getReportPerformanceWeeklyUseCase;
  final GetReportPerformanceMonthlyUseCase getReportPerformanceMonthlyUseCase;

  Future<void> _handleGetReportPerformance(
    GetReportPerformanceEvent event,
    Emitter<ReportPerformanceState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final reportPerformance = await getReportPerformanceUseCase.execute(
      search: event.search,
      limit: event.limit,
      offset: event.offset,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    reportPerformance.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (reportPerformance) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          reportPerformance: reportPerformance,
        ));
      },
    );
  }

  Future<void> _handleGetProductReportPerformance(
    GetReportPerformanceProductEvent event,
    Emitter<ReportPerformanceState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final reportPerformanceProduct = await getReportPerformanceProductUseCase
        .call(keyword: event.keyword, partnerId: event.parentId);

    reportPerformanceProduct.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (reportPerformanceProduct) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          reportPerformanceProduct: reportPerformanceProduct,
        ));
      },
    );
  }

  Future<void> _handleGetWeeklyReportPerformance(
    GetReportPerformanceWeekEvent event,
    Emitter<ReportPerformanceState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final reportPerformanceWeekly =
        await getReportPerformanceWeeklyUseCase.call(
            keyword: event.keyword,
            limit: event.limit.toString(),
            offset: event.offset.toString(),
            week: event.week.toString(),
            productId: event.productId.toString(),
            month: event.month.toString());

    reportPerformanceWeekly.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (reportPerformanceWeekly) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          reportPerformanceWeekly: reportPerformanceWeekly,
        ));
      },
    );
  }

  Future<void> _handleGetMonthlyReportPerformance(
    GetReportPerformanceMonthEvent event,
    Emitter<ReportPerformanceState> emit,
  ) async {
    emit(state.copyWith(
      status: RequestStatus.loading,
    ));

    final reportPerformanceMonthly =
        await getReportPerformanceMonthlyUseCase.call(
      limit: event.limit.toString(),
      offset: event.offset.toString(),
      month: event.month.toString(),
    );

    reportPerformanceMonthly.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              message: failure.message, status: RequestStatus.failure));
        }
      },
      (reportPerformanceMonthly) {
        emit(state.copyWith(
          message: 'Success',
          status: RequestStatus.success,
          reportPerformanceMonthly: reportPerformanceMonthly,
        ));
      },
    );
  }
}
