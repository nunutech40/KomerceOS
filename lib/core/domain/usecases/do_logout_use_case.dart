import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import '../repositories/auth_repository.dart';
import '../services/logout_cleanup_service.dart';

class DoLogoutUseCase {
  final AuthRepository repository;
  final AuthBloc authBloc;
  final LogoutCleanupService? logoutCleanupService;

  DoLogoutUseCase(
    this.repository,
    this.authBloc, {
    this.logoutCleanupService,
  });

  Future<Either<Failure, bool>> execute() async {
    final result = await repository.doLogout();
    try {
      await logoutCleanupService?.cleanup();
    } catch (_) {
      // Push token cleanup is best-effort. Auth logout must still complete.
    }
    authBloc.add(AuthLogoutRequested());
    return result;
  }
}
