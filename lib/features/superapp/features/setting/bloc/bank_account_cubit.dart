import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../domain/entities/bank_account_entry.dart';
import '../domain/repositories/bank_account_repository.dart';

class BankAccountState {
  const BankAccountState({this.loading = false, this.error});
  final bool loading;
  final String? error;
}

class BankAccountCubit extends Cubit<BankAccountState> {
  BankAccountCubit(this._repository) : super(const BankAccountState());
  final BankAccountRepository _repository;

  Future<Either<Failure, T>> _run<T>(Future<Either<Failure, T>> action) async {
    emit(const BankAccountState(loading: true));
    final result = await action;
    result.fold(
      (failure) => emit(BankAccountState(error: failure.message)),
      (_) => emit(const BankAccountState()),
    );
    return result;
  }

  Future<Either<Failure, List<BankAccountEntry>>> accounts() =>
      _run(_repository.accounts());
  Future<Either<Failure, List<AvailableBank>>> banks() =>
      _run(_repository.banks());
  Future<Either<Failure, String?>> owner(String bankCode, String accountNo) =>
      _run(_repository.owner(bankCode, accountNo));
  Future<Either<Failure, BankAccountCheckResult>> checkDuplicate(
          String bankCode, String owner, String accountNo, int userId) =>
      _run(_repository.checkDuplicate(bankCode, owner, accountNo, userId));
  Future<Either<Failure, bool>> whatsappAvailable(String phone) =>
      _run(_repository.whatsappAvailable(phone));
  Future<Either<Failure, BankOtpChallenge>> requestOtp(String method) =>
      _run(_repository.requestOtp(method));
  Future<Either<Failure, BankOtpChallenge?>> restorePendingOtp(String method) =>
      _repository.restorePendingOtp(method);
  Future<Either<Failure, bool>> clearPendingOtp() =>
      _repository.clearPendingOtp();
  Future<Either<Failure, bool>> verifyOtp(String otp, String token) =>
      _run(_repository.verifyOtp(otp, token));
  Future<Either<Failure, bool>> addAccount(
          String token, String bankCode, String accountNo, String owner) =>
      _run(_repository.addAccount(token, bankCode, accountNo, owner));
}
