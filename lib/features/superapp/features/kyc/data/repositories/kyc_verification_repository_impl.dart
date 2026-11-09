import 'package:dio/dio.dart';

import '../../domain/entities/kyc_history.dart';
import '../../domain/repositories/kyc_verification_repository.dart';
import '../datasources/kyc_verification_remote_datasource.dart';
import '../models/kyc_history_response.dart';

class KycVerificationRepositoryImpl implements KycVerificationRepository {
  const KycVerificationRepositoryImpl(this.remote);
  final KycVerificationRemoteDataSource remote;

  @override
  Future<KycHistory?> latestHistory() async {
    try {
      return KycHistoryResponse.parse(await remote.latestHistory());
    } on DioException catch (error) {
      // A new user may have no history yet. Other failures must remain visible.
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> upload(
          {required String ktpPath,
          required String selfieKtpPath,
          required String livenessPath}) =>
      remote.upload(
          ktpPath: ktpPath,
          selfieKtpPath: selfieKtpPath,
          livenessPath: livenessPath);

  @override
  Future<void> checkNik({required String nik, required String email}) =>
      remote.checkNik(nik: nik, email: email);

  @override
  Future<void> submit(Map<String, String> partnerData) =>
      remote.submit(partnerData);
}
