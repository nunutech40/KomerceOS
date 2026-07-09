import 'package:dartz/dartz.dart';
import '../../../common/failure.dart';
import '../entities/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, ProfileModel>> getProfileLocal();
}
