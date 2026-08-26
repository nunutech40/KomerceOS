part of 'attendance_bloc.dart';

class AttendanceState extends Equatable {
  final String messageAttendance;
  final String messageAttendanceFail;
  final String messageAttendanceAbsence;
  final String messageDownloadAttendance;
  final RequestStatus statusAttendance;
  final RequestStatus statusAttendanceFail;
  final RequestStatus statusAttendanceAbsence;
  final RequestStatus statusDownloadAttendance;
  final List<AttendanceModel> attendanceData;
  final List<AttendanceFailModel> attendanceFailData;
  final List<AttendanceAbsenceModel> attendanceAbsenceData;
  final bool isDownloading;

  const AttendanceState({
    this.messageAttendance = '',
    this.messageAttendanceFail = '',
    this.messageAttendanceAbsence = '',
    this.messageDownloadAttendance = '',
    this.statusAttendance = RequestStatus.empty,
    this.statusAttendanceFail = RequestStatus.empty,
    this.statusAttendanceAbsence = RequestStatus.empty,
    this.statusDownloadAttendance = RequestStatus.empty,
    this.attendanceData = const [],
    this.attendanceFailData = const [],
    this.attendanceAbsenceData = const [],
    this.isDownloading = false,
  });

  AttendanceState copyWith(
      {String? messageAttendance,
      String? messageAttendanceFail,
      String? messageAttendanceAbsence,
      String? messageDownloadAttendance,
      RequestStatus? statusAttendance,
      RequestStatus? statusAttendanceFail,
      RequestStatus? statusAttendanceAbsence,
      RequestStatus? statusDownloadAttendance,
      List<AttendanceModel>? attendanceData,
      List<AttendanceFailModel>? attendanceFailData,
      List<AttendanceAbsenceModel>? attendanceAbsenceData,
      bool? isDownloading}) {
    return AttendanceState(
        messageAttendance: messageAttendance ?? this.messageAttendance,
        messageAttendanceFail:
            messageAttendanceFail ?? this.messageAttendanceFail,
        messageAttendanceAbsence:
            messageAttendanceAbsence ?? this.messageAttendanceAbsence,
        messageDownloadAttendance:
            messageDownloadAttendance ?? this.messageDownloadAttendance,
        statusAttendance: statusAttendance ?? this.statusAttendance,
        statusAttendanceFail: statusAttendanceFail ?? this.statusAttendanceFail,
        statusAttendanceAbsence:
            statusAttendanceAbsence ?? this.statusAttendanceAbsence,
        statusDownloadAttendance:
            statusDownloadAttendance ?? this.statusDownloadAttendance,
        attendanceData: attendanceData ?? this.attendanceData,
        attendanceFailData: attendanceFailData ?? this.attendanceFailData,
        attendanceAbsenceData:
            attendanceAbsenceData ?? this.attendanceAbsenceData,
        isDownloading: isDownloading ?? this.isDownloading);
  }

  @override
  List<Object?> get props => [
        messageAttendance,
        messageAttendanceFail,
        messageAttendanceAbsence,
        messageDownloadAttendance,
        statusAttendance,
        statusAttendanceFail,
        statusAttendanceAbsence,
        statusDownloadAttendance,
        attendanceData,
        attendanceFailData,
        attendanceAbsenceData,
        isDownloading
      ];
}
