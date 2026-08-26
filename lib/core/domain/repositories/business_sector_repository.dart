import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/business_sector_model.dart';

abstract class BusinessSectorRepository {
  Future<Either<Failure, List<BusinessSectorModel>>> getBusinessSectors();
}
