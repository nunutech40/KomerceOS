import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';

import '../datasources/remote/attendance_remote_datasource.dart';

class AttendanceRepositoryImp extends BaseRepository
    implements AttendanceRepostiory {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImp({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AttendanceModel>>> getAttendance(
      int offset, int limit, String name, String startDate, String endDate) {
    return executeEither(() async {
      final result = await remoteDataSource.getAttendance(
          offset, limit, name, startDate, endDate);
      final attendanceData = result.map((item) => item.toEntity()).toList();
      return attendanceData;
    });
  }

  @override
  Future<Either<Failure, List<AttendanceFailModel>>> getAttendanceFail(
      int offset, int limit, String name, String startDate, String endDate) {
    return executeEither(() async {
      final result = await remoteDataSource.getAttendanceFail(
          offset, limit, name, startDate, endDate);
      final attendanceFailData = result.map((item) => item.toEntity()).toList();
      return attendanceFailData;
    });
  }

  @override
  Future<Either<Failure, List<AttendanceAbsenceModel>>> getAttendanceAbsense(
      String name, String startDate, String endDate) {
    return executeEither(() async {
      final result =
          await remoteDataSource.getAttendanceAbsense(name, startDate, endDate);
      final attendanceAbsenceData =
          result.map((item) => item.toEntity()).toList();
      return attendanceAbsenceData;
    });
  }

  @override
  Future<Either<Failure, Uint8List>> downloadAttendance(
      String startDate, String endDate) {
    return executeEither(() async {
      final result =
          await remoteDataSource.downloadAttendance(startDate, endDate);
      return result;
    });
  }
}
