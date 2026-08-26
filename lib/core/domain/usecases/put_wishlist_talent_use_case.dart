import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/repositories/resource_talent_repository.dart';

class PutWishlistTalentUseCase {
  final ResourceTalentRepository repository;

  PutWishlistTalentUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int talentId) {
    return repository.putWishlist(talentId);
  }
}
