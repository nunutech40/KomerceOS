import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/usecases/get_attendance_absences_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_attendance_fail_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/get_attendance_use_case.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../common/enum_status.dart';
import '../../../../../../common/failure.dart';
import '../../../../../../core/domain/usecases/download_attendance.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendanceUsecase getAttendanceUsecase;
  final GetAttendanceFailUsecase getAttendanceFailUsecase;
  final GetAttedanceAbsenceUsecase getAttedanceAbsenceUsecase;
  final AttendanceDownloadUsecase attendanceDownloadUsecase;

  AttendanceBloc({
    required this.getAttendanceUsecase,
    required this.getAttendanceFailUsecase,
    required this.getAttedanceAbsenceUsecase,
    required this.attendanceDownloadUsecase,
  }) : super(const AttendanceState()) {
    on<GetAttendanceEvent>(_handleGetAttendance);
    on<GetAttendanceFailEvent>(_handleGetAttendanceFail);
    on<GetAttendanceAbsenceEvent>(_handleGetAttendanceAbsence);
    on<DownloadAttendanceEvent>(_handleDownloadAttendance);
    on<ResetAttendanceEvent>(_handleResetAttendance);
  }

  Future<void> _handleGetAttendance(
    GetAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(statusAttendance: RequestStatus.loading));

    final attendanceResult = await getAttendanceUsecase.execute(
        event.offset, event.limit, event.name, event.startDate, event.endDate);

    attendanceResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              messageAttendance: failure.message,
              statusAttendance: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              messageAttendance: failure.message,
              statusAttendance: RequestStatus.empty));
        }
      },
      (attendanceData) {
        emit(state.copyWith(
            messageAttendance: 'Success',
            statusAttendance: RequestStatus.success,
            attendanceData: attendanceData));
      },
    );
  }

  Future<void> _handleGetAttendanceFail(
    GetAttendanceFailEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(statusAttendanceFail: RequestStatus.loading));
    final attendanceResult = await getAttendanceFailUsecase.execute(
        event.offset, event.limit, event.name, event.startDate, event.endDate);

    attendanceResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              messageAttendanceFail: failure.message,
              statusAttendanceFail: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              messageAttendanceFail: failure.message,
              statusAttendanceFail: RequestStatus.empty));
        }
      },
      (attendanceFailData) {
        emit(state.copyWith(
            messageAttendanceFail: 'Success',
            statusAttendanceFail: RequestStatus.success,
            attendanceFailData: attendanceFailData));
      },
    );
  }

  Future<void> _handleGetAttendanceAbsence(
    GetAttendanceAbsenceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(statusAttendanceAbsence: RequestStatus.loading));
    final attendanceResult = await getAttedanceAbsenceUsecase.execute(
        event.name, event.startDate, event.endDate);

    attendanceResult.fold(
      (failure) {
        if (failure is ConnectionFailure || failure is ServerFailure) {
          emit(state.copyWith(
              messageAttendanceAbsence: failure.message,
              statusAttendanceAbsence: RequestStatus.failure));
        } else {
          emit(state.copyWith(
              messageAttendanceAbsence: failure.message,
              statusAttendanceAbsence: RequestStatus.empty));
        }
      },
      (attendanceAbsenceData) {
        emit(state.copyWith(
            messageAttendanceAbsence: 'Success',
            statusAttendanceAbsence: RequestStatus.success,
            attendanceAbsenceData: attendanceAbsenceData));
      },
    );
  }

  Future<void> _handleDownloadAttendance(
    DownloadAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
        isDownloading: true, statusDownloadAttendance: RequestStatus.loading));

    final result =
        await attendanceDownloadUsecase.execute(event.startDate, event.endDate);

    if (result.isRight()) {
      emit(state.copyWith(isDownloading: false));

      try {
        Directory? directory;

        if (Platform.isAndroid) {
          // App-specific external storage does not require storage permission.
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception("Unable to get directory");
        }

        // Create a file path with timestamp
        final filePath =
            '${directory.path}/presensi_${event.startDate}_${event.endDate}.pdf';

        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(result.getOrElse(() => Uint8List.fromList([])));
        emit(state.copyWith(
            statusDownloadAttendance: RequestStatus.success,
            isDownloading: false));
        // Open the file
        final openResult =
            await OpenFile.open(filePath, type: 'application/pdf');
        if (openResult.type != ResultType.done) {
          throw Exception(openResult.message);
        }
      } catch (e) {
        emit(state.copyWith(
            messageDownloadAttendance:
                "Error while downloading and opening the file",
            statusDownloadAttendance: RequestStatus.failure,
            isDownloading: false));
      }
    } else {
      emit(state.copyWith(
          messageDownloadAttendance: result.fold((l) => l.message, (r) => ''),
          statusDownloadAttendance: RequestStatus.failure,
          isDownloading: false));
    }
  }

  Future<void> _handleResetAttendance(
    ResetAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceState());
  }
}
