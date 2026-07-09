import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../managers/authentication_manager.dart';
import '../repositories/auth_repository.dart';
import '../services/logout_cleanup_service.dart';

class DoLogoutUseCase {
  final AuthRepository repository;
  final AuthenticationManager authenticationManager;
  final LogoutCleanupService? logoutCleanupService;

  DoLogoutUseCase(
    this.repository,
    this.authenticationManager, {
    this.logoutCleanupService,
  });

  Future<Either<Failure, bool>> execute() async {
    final result = await repository.doLogout();
    try {
      await logoutCleanupService?.cleanup();
    } catch (_) {
      // Push token cleanup is best-effort. Auth logout must still complete.
    }
    await authenticationManager.logout();
    return result;
  }
}
