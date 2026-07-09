import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/login_model.dart';
import '../managers/authentication_manager.dart';
import '../repositories/auth_repository.dart';
import 'get_profile_use_case.dart';

class DoLoginUseCase {
  final AuthRepository repository;
  final GetProfileUseCase getProfileUseCase;
  final AuthenticationManager authenticationManager;

  DoLoginUseCase(
      this.repository, this.getProfileUseCase, this.authenticationManager);

  Future<Either<Failure, LoginModel>> execute(
      String username, String password, {String? recaptchaToken}) async {
    final dataLogin = await repository.doLogin(username, password, recaptchaToken: recaptchaToken);
    await dataLogin.fold((l) async {}, (r) async {
      if (r.data != null) {
        await authenticationManager.login(r.data!);
      }
      await getProfileUseCase.execute();
    });
    return dataLogin;
  }
}
