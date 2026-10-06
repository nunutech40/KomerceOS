import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/entities/verify_pin_model.dart';
import 'package:komtim_partner/core/domain/repositories/pin_repository.dart';

enum AccountPinOperation { idle, loading, success, failure }

class AccountPinState {
  const AccountPinState(
      {this.operation = AccountPinOperation.idle, this.error});
  final AccountPinOperation operation;
  final String? error;
}

/// API orchestration for the new Superapp PIN screens. The legacy PinBloc is
/// kept for the older withdrawal screens.
class AccountPinCubit extends Cubit<AccountPinState> {
  AccountPinCubit(this._repository) : super(const AccountPinState());

  final PinRepository _repository;

  Future<Either<Failure, T>> _run<T>(Future<Either<Failure, T>> action) async {
    emit(const AccountPinState(operation: AccountPinOperation.loading));
    final result = await action;
    result.fold(
      (failure) => emit(AccountPinState(
          operation: AccountPinOperation.failure, error: failure.message)),
      (_) =>
          emit(const AccountPinState(operation: AccountPinOperation.success)),
    );
    return result;
  }

  Future<Either<Failure, int>> attemptLeft() =>
      _run(_repository.getAttemptLeft());

  Future<Either<Failure, VerifyPinModel>> verifyPin(String pin) =>
      _run(_repository.verifyPin(pin));

  Future<Either<Failure, DataOtpModel>> requestOtp() =>
      _run(_repository.forgetPin(purpose: 'pin'));

  Future<Either<Failure, DataOtpModel?>> restorePendingOtp() =>
      _repository.restorePendingOtp();

  Future<Either<Failure, bool>> clearPendingOtp() =>
      _repository.clearPendingOtp();

  Future<Either<Failure, VerifyPinModel>> verifyOtp(String otp, String token) =>
      _run(_repository.verifyOtp(otp, token: token));

  Future<Either<Failure, bool>> createPin(String pin) =>
      _run(_repository.savePin(pin));

  Future<Either<Failure, bool>> changePin(
          String pin, String oldPin, String token) =>
      _run(_repository.changePin(pin, oldPin, token));

  Future<Either<Failure, bool>> resetPin(String pin, String token) =>
      _run(_repository.updatePinSecured(pin, token));
}
