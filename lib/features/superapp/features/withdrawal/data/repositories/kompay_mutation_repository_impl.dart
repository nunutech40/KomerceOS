import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/datasources/kompay_mutation_remote_datasource.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/repositories/kompay_mutation_repository.dart';

class KompayMutationRepositoryImpl extends BaseRepository
    implements KompayMutationRepository {
  KompayMutationRepositoryImpl({required this.remoteDataSource});

  final KompayMutationRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, KompayMutationResult>> getMutations({
    required int page,
    String? filter,
    String? search,
  }) {
    return executeEither(() => remoteDataSource.getMutations(
        page: page, filter: filter, search: search));
  }
}
