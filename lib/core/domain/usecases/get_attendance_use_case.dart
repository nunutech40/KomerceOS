import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';

import '../../../common/failure.dart';

class GetAttendanceUsecase {
  final AttendanceRepostiory _repository;

  const GetAttendanceUsecase(this._repository);

  Future<Either<Failure, List<AttendanceModel>>> execute(
      int offset, int limit, String name, String startDate, String endDate) {
    return _repository.getAttendance(offset, limit, name, startDate, endDate);
  }
}
