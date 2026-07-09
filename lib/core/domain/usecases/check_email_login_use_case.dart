import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/check_email_model.dart';
import '../repositories/auth_repository.dart';

// -----------------------------------------------------------------------------
// CheckEmailLoginUseCase
//
// Memanggil endpoint check-login untuk mengetahui status email:
//   - "registered"   → lanjut ke halaman login (masukkan password)
//   - "unregistered" → email belum terdaftar, arahkan ke pendaftaran
//   - "unverified"   → email belum diverifikasi, kirim ulang email verifikasi
// -----------------------------------------------------------------------------

class CheckEmailLoginUseCase {
  final AuthRepository repository;

  CheckEmailLoginUseCase(this.repository);

  Future<Either<Failure, CheckEmailModel>> call(String email, {String? recaptchaToken}) {
    return repository.checkEmailLogin(email, recaptchaToken: recaptchaToken);
  }
}
