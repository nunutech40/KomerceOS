import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/data/datasources/preferences/secure_storage_service.dart';
import '../../domain/entities/bank_account_entry.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_remote_datasource.dart';
import '../models/bank_account_response.dart';

class BankAccountRepositoryImpl extends BaseRepository
    implements BankAccountRepository {
  BankAccountRepositoryImpl(this.remote, this.secureStorage);
  final BankAccountRemoteDataSource remote;
  final SecureStorageService secureStorage;

  @override
  Future<Either<Failure, List<BankAccountEntry>>> accounts() =>
      executeEither(() async => (await remote.accounts()).accounts);

  @override
  Future<Either<Failure, List<AvailableBank>>> banks() =>
      executeEither(() async => (await remote.banks()).banks);

  @override
  Future<Either<Failure, String?>> owner(String bankCode, String accountNo) =>
      executeEither(
          () async => (await remote.owner(bankCode, accountNo)).accountName);

  @override
  Future<Either<Failure, bool>> checkDuplicate(
          String bankCode, String owner, String accountNo, int userId) =>
      executeEither(() async {
        await remote.checkDuplicate(bankCode, owner, accountNo, userId);
        return true;
      });

  @override
  Future<Either<Failure, BankOtpChallenge>> requestOtp(String method) =>
      executeEither(() async {
        final challenge = (await remote.requestOtp(method)).challenge;
        await secureStorage.saveOtpChallenge('rekening', {
          'method': method,
          'token': challenge.token,
          'next_request_at': challenge.nextRequestAt.toIso8601String(),
          if (challenge.expiredAt != null)
            'expired_at': challenge.expiredAt!.toIso8601String(),
        });
        return challenge;
      });

  @override
  Future<Either<Failure, BankOtpChallenge?>> restorePendingOtp(String method) =>
      executeEither(() async {
        final stored = await secureStorage.readOtpChallenge('rekening');
        if (stored == null || stored['method'] != method) return null;
        return BankOtpResponse.fromJson(stored).challenge;
      });

  @override
  Future<Either<Failure, bool>> clearPendingOtp() => executeEither(() async {
        await secureStorage.clearOtpChallenge('rekening');
        return true;
      });

  @override
  Future<Either<Failure, bool>> verifyOtp(String otp, String token) =>
      executeEither(() async {
        await remote.verifyOtp(otp, token);
        return true;
      });

  @override
  Future<Either<Failure, bool>> addAccount(
          String token, String bankCode, String accountNo, String owner) =>
      executeEither(() async {
        await remote.addAccount(token, bankCode, accountNo, owner);
        try {
          await secureStorage.clearOtpChallenge('rekening');
        } catch (_) {
          // The server has already saved the account; a local cleanup failure
          // must not make the UI retry the mutation.
        }
        return true;
      });
}
