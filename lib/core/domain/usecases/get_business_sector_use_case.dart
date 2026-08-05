import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';
import 'package:komtim_partner/core/domain/repositories/business_sector_repository.dart';

class GetBusinessSectorUseCase {
  final BusinessSectorRepository repository;

  GetBusinessSectorUseCase(this.repository);

  Future<Either<Failure, List<BusinessSectorModel>>> call() {
    return repository.getBusinessSectors();
  }
}
