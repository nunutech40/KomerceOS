import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/business_sector_datasource.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';
import 'package:komtim_partner/core/domain/repositories/business_sector_repository.dart';

class BusinessSectorRepositoryImpl extends BaseRepository
    implements BusinessSectorRepository {
  final BusinessSectorRemoteDataSource remoteDataSource;

  BusinessSectorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BusinessSectorModel>>> getBusinessSectors() {
    return executeEither(() async {
      final result = await remoteDataSource.getBusinessSectors();
      return result.map((item) => item.toEntity()).toList();
    });
  }
}
