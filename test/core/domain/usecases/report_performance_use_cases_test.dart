import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_model.dart';
import 'package:komtim_partner/core/domain/entities/report_performance_monthly_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_monthly_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_report_performance_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/mocks/mocks.dart';

void main() {
  late MockReportPerformanceRepository repository;

  setUp(() {
    repository = MockReportPerformanceRepository();
  });

  group('Report performance filter use cases', () {
    test('daily forwards the selected date range to the repository', () async {
      final useCase = GetReportPerformanceUseCase(repository);
      const expected = <ReportPerformanceModel>[];

      when(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-21',
        endDate: '2026-09-21',
      )).thenAnswer((_) async => const Right(expected));

      final result = await useCase.execute(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-21',
        endDate: '2026-09-21',
      );

      expect(result, const Right(expected));
      verify(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-21',
        endDate: '2026-09-21',
      )).called(1);
    });

    test('custom daily filter forwards both selected dates', () async {
      final useCase = GetReportPerformanceUseCase(repository);
      const expected = <ReportPerformanceModel>[];

      when(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      )).thenAnswer((_) async => const Right(expected));

      final result = await useCase.execute(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      );

      expect(result, const Right(expected));
      verify(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      )).called(1);
    });

    test('weekly uses the list use case with the selected week date range',
        () async {
      final useCase = GetReportPerformanceUseCase(repository);
      const expected = <ReportPerformanceModel>[];

      when(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      )).thenAnswer((_) async => const Right(expected));

      final result = await useCase.execute(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      );

      expect(result, const Right(expected));
      verify(repository.getReportPerformance(
        search: '',
        limit: '10',
        offset: '0',
        startDate: '2026-09-14',
        endDate: '2026-09-20',
      )).called(1);
    });

    test('monthly forwards the selected month', () async {
      final useCase = GetReportPerformanceMonthlyUseCase(repository);
      const expected = <ReportPerformanceMonthlyModel>[];

      when(repository.getMonthlyReportPerformance(
        limit: '10',
        offset: '0',
        month: '9',
      )).thenAnswer((_) async => const Right(expected));

      final result = await useCase.call(
        limit: '10',
        offset: '0',
        month: '9',
      );

      expect(result, const Right(expected));
      verify(repository.getMonthlyReportPerformance(
        limit: '10',
        offset: '0',
        month: '9',
      )).called(1);
    });
  });
}
