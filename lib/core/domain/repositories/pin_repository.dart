import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/check_pin_model.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import '../../../common/failure.dart';

abstract class PinRepository {
  Future<Either<Failure, ChekPinModel>> checkPin();
  Future<Either<Failure, VerifyPinModel>> verifyPin(String pin);
  Future<Either<Failure, bool>> savePin(String pin);
  Future<Either<Failure, DataOtpModel>> forgetPin();
  Future<Either<Failure, VerifyPinModel>> verifyOtp(String otp);
  Future<Either<Failure, bool>> saveTime(String time);
  Future<Either<Failure, bool>> deleteTime();
  Future<Either<Failure, DataOtpModel>> getTime();
}
