import '../entities/kyc_history.dart';

abstract class KycVerificationRepository {
  Future<KycHistory?> latestHistory();
  Future<void> upload({
    String? ktpPath,
    String? selfieKtpPath,
    String? livenessPath,
  });
  Future<void> checkNik({required String nik, required String email});
  Future<void> submit(Map<String, String> partnerData);
}
