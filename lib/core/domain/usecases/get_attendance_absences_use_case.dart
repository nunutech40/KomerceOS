import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/attendance_model.dart';
import 'package:komtim_partner/core/domain/repositories/attendance_repository.dart';

import '../../../common/failure.dart';

class GetAttedanceAbsenceUsecase {
  final AttendanceRepostiory _repository;

  const GetAttedanceAbsenceUsecase(this._repository);

  Future<Either<Failure, List<AttendanceAbsenceModel>>> execute(
      String name, String startDate, String endDate) {
    return _repository.getAttendanceAbsense(name, startDate, endDate);
  }
}
