import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';

import '../../../common/failure.dart';

class GetAttendanceFailUsecase {
  final AttendanceRepostiory _repository;

  const GetAttendanceFailUsecase(this._repository);

  Future<Either<Failure, List<AttendanceFailModel>>> execute(
      int offset, int limit, String name, String startDate, String endDate) {
    return _repository.getAttendanceFail(
        offset, limit, name, startDate, endDate);
  }
}
