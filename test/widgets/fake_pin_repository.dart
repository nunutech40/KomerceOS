import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

class FakePinRepository implements PinRepository {
  FakePinRepository({DateTime Function()? now}) : now = now ?? DateTime.now;
  final DateTime Function() now;
  bool hasPin = false;
  int attemptLeft = 3;
  int otpRequests = 0;
  Completer<Either<Failure, bool>>? pendingSave;
  DataOtpModel? pendingOtp;

  @override
  Future<Either<Failure, int>> getAttemptLeft() async => Right(attemptLeft);

  @override
  Future<Either<Failure, VerifyPinModel>> verifyPin(String pin) async {
    if (pin == '123456') {
      return const Right(VerifyPinModel(
          isValid: true, usableToken: 'usable-token', attemptLeft: 3));
    }
    attemptLeft--;
    return Right(VerifyPinModel(isValid: false, attemptLeft: attemptLeft));
  }

  @override
  Future<Either<Failure, DataOtpModel>> forgetPin({String? purpose}) async {
    otpRequests++;
    pendingOtp = DataOtpModel(
      expiredAt: now().add(const Duration(minutes: 10)).toIso8601String(),
      token: 'otp-token',
      nextRequestAt:
          now().add(Duration(seconds: otpRequests * 60)).toIso8601String(),
    );
    return Right(pendingOtp!);
  }

  @override
  Future<Either<Failure, DataOtpModel?>> restorePendingOtp() async =>
      Right(pendingOtp);

  @override
  Future<Either<Failure, bool>> clearPendingOtp() async {
    pendingOtp = null;
    return const Right(true);
  }

  @override
  Future<Either<Failure, VerifyPinModel>> verifyOtp(String otp,
          {String? token}) async =>
      Right(VerifyPinModel(isValid: otp == '123456'));

  @override
  Future<Either<Failure, bool>> savePin(String pin) async {
    if (pendingSave != null) await pendingSave!.future;
    hasPin = true;
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> changePin(
          String pin, String oldPin, String token) async =>
      const Right(true);

  @override
  Future<Either<Failure, bool>> updatePinSecured(
          String pin, String token) async =>
      const Right(true);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
