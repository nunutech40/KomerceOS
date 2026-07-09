import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';

import '../../../common/failure.dart';

class AttendanceDownloadUsecase {
  final AttendanceRepostiory _repository;

  const AttendanceDownloadUsecase(this._repository);

  Future<Either<Failure, Uint8List>> execute(String startDate, String endDate) {
    return _repository.downloadAttendance(startDate, endDate);
  }
}
