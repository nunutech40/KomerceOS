import '../entities/kyc_history.dart';

abstract class KycVerificationRepository {
  Future<KycHistory?> latestHistory();
  Future<void> upload({
    required String ktpPath,
    required String selfieKtpPath,
    required String livenessPath,
  });
  Future<void> checkNik({required String nik, required String email});
  Future<void> submit(Map<String, String> partnerData);
}
