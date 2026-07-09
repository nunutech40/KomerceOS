import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../../domain/entities/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/preferences/shared_pref.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import 'base_repository.dart';

class ProfileRepositoryImpl extends BaseRepository
    implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;

  ProfileRepositoryImpl(
      {required this.remoteDataSource, required this.sharedPref});

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    return executeEither(() async {
      final result = await remoteDataSource.getProfile();
      final profileModel = result.toEntity();
      sharedPref.saveProfileData(result);
      return profileModel;
    });
  }

  @override
  Future<Either<Failure, ProfileModel>> getProfileLocal() {
    return executeEither(() async {
      final result = await sharedPref.getProfileResponse();
      return result!.toEntity();
    });
  }
}
