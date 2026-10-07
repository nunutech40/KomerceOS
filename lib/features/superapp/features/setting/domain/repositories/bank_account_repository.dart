import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import '../entities/bank_account_entry.dart';

abstract class BankAccountRepository {
  Future<Either<Failure, List<BankAccountEntry>>> accounts();
  Future<Either<Failure, List<AvailableBank>>> banks();
  Future<Either<Failure, String?>> owner(String bankCode, String accountNo);
  Future<Either<Failure, BankAccountCheckResult>> checkDuplicate(
      String bankCode, String owner, String accountNo, int userId);
  Future<Either<Failure, bool>> whatsappAvailable(String phone);
  Future<Either<Failure, BankOtpChallenge>> requestOtp(String method);
  Future<Either<Failure, BankOtpChallenge?>> restorePendingOtp(String method);
  Future<Either<Failure, bool>> clearPendingOtp();
  Future<Either<Failure, bool>> verifyOtp(String otp, String token);
  Future<Either<Failure, bool>> addAccount(
      String token, String bankCode, String accountNo, String owner);
}
