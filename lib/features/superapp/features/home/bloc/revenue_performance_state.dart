part of 'revenue_performance_bloc.dart';

abstract class RevenuePerformanceState extends Equatable {
  const RevenuePerformanceState();

  @override
  List<Object?> get props => [];
}

class RevenuePerformanceInitial extends RevenuePerformanceState {}

class RevenuePerformanceLoading extends RevenuePerformanceState {}

class RevenuePerformanceLoaded extends RevenuePerformanceState {
  final RevenuePerformanceModel data;

  const RevenuePerformanceLoaded(this.data);

  /// Total omset bulan ini — siap pakai langsung di UI.
  num get totalOmset => data.totalProfit ?? 0;

  /// Data omset per hari dalam format FlSpot, sudah di-sort dan valid.
  /// UI tidak perlu tahu cara parsing "2025-07-24" → FlSpot.
  List<FlSpot> get omzetSpots => _buildSpots(
        (day) => (day.totalProfit ?? 0).toDouble(),
      );

  /// Data order per hari dalam format FlSpot, sudah di-sort dan valid.
  List<FlSpot> get orderSpots => _buildSpots(
        (day) => (day.totalOrder ?? 0).toDouble(),
      );

  List<FlSpot> _buildSpots(
      double Function(RevenuePerformanceDayModel day) valueSelector) {
    final days = data.dataDays ?? [];
    final spots = <FlSpot>[];

    for (int i = 0; i < days.length; i++) {
      final parts = (days[i].day ?? '').split('-');
      if (parts.length == 3) {
        final x = double.tryParse(parts[2]) ?? (i.toDouble() + 1);
        spots.add(FlSpot(x, valueSelector(days[i])));
      }
    }

    // FlChart mensyaratkan spots ascending berdasarkan X
    spots.sort((a, b) => a.x.compareTo(b.x));

    // FlChart isCurved: true minimal butuh 2 points
    if (spots.isEmpty) {
      return [const FlSpot(1, 0), const FlSpot(31, 0)];
    } else if (spots.length == 1) {
      return [...spots, FlSpot(spots.first.x + 1, spots.first.y)];
    }

    return spots;
  }

  @override
  List<Object?> get props => [data];
}

class RevenuePerformanceError extends RevenuePerformanceState {
  final Failure failure;

  const RevenuePerformanceError(this.failure);

  bool get isServerError => failure is ServerFailure;
  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
