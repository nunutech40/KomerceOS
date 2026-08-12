import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';

import '../entities/team_member_model.dart';

abstract class TeamRepository {
  Future<Either<Failure, List<TeamMemberModel>>> getInternalTeams(
      String search);
  Future<Either<Failure, List<TeamMemberModel>>> getKomtimTeams(String search);
}
