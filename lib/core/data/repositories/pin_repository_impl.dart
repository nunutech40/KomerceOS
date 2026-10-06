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
  Future<Either<Failure, ChekPinModel>> checkPinSetting() async {
    return executeEither(() async {
      final result = await remoteDataSource.checkPinSetting();
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
  Future<Either<Failure, int>> getAttemptLeft() =>
      executeEither(() => remoteDataSource.getAttemptLeft());

  @override
  Future<Either<Failure, bool>> changePin(
          String pin, String oldPin, String token) =>
      executeEither(() => remoteDataSource.changePin(pin, oldPin, token));

  @override
  Future<Either<Failure, DataOtpModel>> forgetPin({String? purpose}) async {
    return executeEither(() async {
      final result = await remoteDataSource.forgetPin(purpose: purpose);
      if (result.token != null && result.nextRequestAt != null) {
        await sharedPref.secureStorage.saveOtpChallenge('pin', {
          'token': result.token!,
          'next_request_at': result.nextRequestAt!,
          'expired_at': result.expiredAt,
        });
      }
      final otpModel = result.toEntity();
      return otpModel;
    });
  }

  @override
  Future<Either<Failure, DataOtpModel?>> restorePendingOtp() =>
      executeEither(() async {
        final stored = await sharedPref.secureStorage.readOtpChallenge('pin');
        if (stored == null) return null;
        return DataOtpModel(
          token: stored['token'],
          nextRequestAt: stored['next_request_at'],
          expiredAt: stored['expired_at'] ?? '',
        );
      });

  @override
  Future<Either<Failure, bool>> clearPendingOtp() => executeEither(() async {
        await sharedPref.secureStorage.clearOtpChallenge('pin');
        return true;
      });

  @override
  Future<Either<Failure, VerifyPinModel>> verifyOtp(String otp,
      {String? token}) async {
    return executeEither(() async {
      final result = await remoteDataSource.verifyOtp(otp, token: token);
      final otpModel = result.toEntity();
      return otpModel;
    });
  }

  @override
  Future<Either<Failure, bool>> updatePinSecured(String pin, String token) {
    return executeEither(() async {
      final result = await remoteDataSource.updatePinSecured(pin, token);
      if (result) {
        try {
          await sharedPref.secureStorage.clearOtpChallenge('pin');
        } catch (_) {
          // PIN update succeeded remotely; avoid a duplicate update.
        }
      }
      return result;
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
