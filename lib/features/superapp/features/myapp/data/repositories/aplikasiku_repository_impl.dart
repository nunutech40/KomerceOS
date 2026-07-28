import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import '../../domain/entities/aplikasiku_entity.dart';
import '../../domain/repositories/aplikasiku_repository.dart';
import '../datasource/aplikasiku_remote_datasource.dart';

class AplikasikuRepositoryImpl extends BaseRepository implements AplikasikuRepository {
  final AplikasikuRemoteDataSource remoteDataSource;

  AplikasikuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AplikasiItemEntity>>> getAplikasiku() async {
    return executeEither<List<AplikasiItemEntity>>(() async {
      final response = await remoteDataSource.getAplikasiku();
      return response.toEntityList();
    });
  }
}
