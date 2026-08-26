import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';

import '../entities/team_member_model.dart';
import '../repositories/team_repository.dart';

class GetInternalTeamsUseCase {
  final TeamRepository repository;

  GetInternalTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamMemberModel>>> call(String search) {
    return repository.getInternalTeams(search);
  }
}
