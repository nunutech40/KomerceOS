import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../entities/aplikasiku_entity.dart';

abstract class AplikasikuRepository {
  Future<Either<Failure, List<AplikasiItemEntity>>> getAplikasiku();
}
