import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../entities/aplikasiku_entity.dart';
import '../repositories/aplikasiku_repository.dart';

class GetAplikasikuListUseCase {
  final AplikasikuRepository repository;

  GetAplikasikuListUseCase(this.repository);

  Future<Either<Failure, List<AplikasiItemEntity>>> call() {
    return repository.getAplikasiku();
  }
}
