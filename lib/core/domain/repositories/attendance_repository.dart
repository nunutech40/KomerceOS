import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';

import '../../../common/failure.dart';

abstract class AttendanceRepostiory {
  Future<Either<Failure, List<AttendanceModel>>> getAttendance(
      int offset, int limit, String name, String startDate, String endDate);
  Future<Either<Failure, List<AttendanceFailModel>>> getAttendanceFail(
      int offset, int limit, String name, String startDate, String endDate);
  Future<Either<Failure, List<AttendanceAbsenceModel>>> getAttendanceAbsense(
      String name, String startDate, String endDate);
  Future<Either<Failure, Uint8List>> downloadAttendance(
      String startDate, String endDate);
}
