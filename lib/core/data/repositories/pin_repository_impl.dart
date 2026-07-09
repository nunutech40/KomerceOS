import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';
import '../../domain/entities/check_pin_model.dart';
import '../datasources/remote/pin_remote_datasource.dart';
import 'base_repository.dart';

class PinRepositoryImpl extends BaseRepository implements PinRepository {
  final PinRemoteDataSource remoteDataSource;
  final SharedPref sharedPref;

  PinRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPref,
  });

  @override
  Future<Either<Failure, ChekPinModel>> checkPin() async {
    return executeEither(() async {
      final result = await remoteDataSource.checkPin();
      final pinModel = result.toEntity();
      return pinModel;
    });
  }

  @override
  Future<Either<Failure, bool>> savePin(String pin) async {
    return executeEither(() async {
      final result = await remoteDataSource.savePin(pin);
      return result;
    });
  }

  @override
  Future<Either<Failure, VerifyPinModel>> verifyPin(String pin) async {
    return executeEither(() async {
      final result = await remoteDataSource.verifyPin(pin);
      final pinModel = result.toEntity();
      return pinModel;
    });
  }

  @override
  Future<Either<Failure, DataOtpModel>> forgetPin() async {
    return executeEither(() async {
      final result = await remoteDataSource.forgetPin();
      final otpModel = result.toEntity();
      return otpModel;
    });
  }

  @override
  Future<Either<Failure, VerifyPinModel>> verifyOtp(String otp) async {
    return executeEither(() async {
      final result = await remoteDataSource.verifyOtp(otp);
      final otpModel = result.toEntity();
      return otpModel;
    });
  }

  @override
  Future<Either<Failure, bool>> saveTime(String time) async {
    return executeEither(() async {
      final result = await sharedPref.saveTime(time);
      return result;
    });
  }

    @override
  Future<Either<Failure, bool>> deleteTime() async {
    return executeEither(() async {
      final result = await sharedPref.deleteTime();
      return result;
    });
  }

  @override
  Future<Either<Failure, DataOtpModel>> getTime() {
    return executeEither(() async {
      final result = await sharedPref.getTime();
      final otpModel = result.toEntity();
      return otpModel;
    });
  }
}
