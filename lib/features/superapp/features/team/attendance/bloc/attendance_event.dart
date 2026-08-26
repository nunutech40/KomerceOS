part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class GetAttendanceEvent extends AttendanceEvent {
  final int offset;
  final int limit;
  final String name;
  final String startDate;
  final String endDate;

  const GetAttendanceEvent({
    required this.offset,
    required this.limit,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        offset,
        limit,
        name,
        startDate,
        endDate,
      ];
}

class GetAttendanceFailEvent extends AttendanceEvent {
  final int offset;
  final int limit;
  final String name;
  final String startDate;
  final String endDate;

  const GetAttendanceFailEvent({
    required this.offset,
    required this.limit,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        offset,
        limit,
        name,
        startDate,
        endDate,
      ];
}

class GetAttendanceAbsenceEvent extends AttendanceEvent {
  final String name;
  final String startDate;
  final String endDate;

  const GetAttendanceAbsenceEvent({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        name,
        startDate,
        endDate,
      ];
}

class DownloadAttendanceEvent extends AttendanceEvent {
  final String startDate;
  final String endDate;

  const DownloadAttendanceEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
      ];
}

class ResetAttendanceEvent extends AttendanceEvent {
  const ResetAttendanceEvent();

  @override
  List<Object?> get props => [];
}
