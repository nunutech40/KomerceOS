import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';

import '../../domain/entities/team_member_model.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/remote/team_remote_datasource.dart';
import 'base_repository.dart';

class TeamRepositoryImpl extends BaseRepository implements TeamRepository {
  final TeamRemoteDataSource remoteDataSource;

  TeamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TeamMemberModel>>> getInternalTeams(
      String search) async {
    return executeEither(() async {
      final response = await remoteDataSource.getInternalTeams(search);
      return response.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<TeamMemberModel>>> getKomtimTeams(
      String search) async {
    return executeEither(() async {
      final response = await remoteDataSource.getKomtimTeams(search);
      return response.map((e) => e.toEntity()).toList();
    });
  }
}
