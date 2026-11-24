import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';

abstract class KompayMutationRepository {
  Future<Either<Failure, KompayMutationResult>> getMutations({
    required int page,
    String? filter,
    String? search,
  });
}
