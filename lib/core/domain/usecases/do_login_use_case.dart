import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/login_model.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import '../repositories/auth_repository.dart';
import 'get_profile_use_case.dart';

class DoLoginUseCase {
  final AuthRepository repository;
  final GetProfileUseCase getProfileUseCase;
  final AuthBloc authBloc;

  DoLoginUseCase(
      this.repository, this.getProfileUseCase, this.authBloc);

  Future<Either<Failure, LoginModel>> execute(
      String username, String password, {String? recaptchaToken}) async {
    final dataLogin = await repository.doLogin(username, password, recaptchaToken: recaptchaToken);
    await dataLogin.fold((l) async {}, (r) async {
      if (r.data != null) {
        authBloc.add(AuthLoginRequested(r.data!));
      }
      // TEMPORARY: Di-comment sementara karena endpoint profile ini yang men-trigger 401
      // dan membuat user terlempar ke login lagi.
      // await getProfileUseCase.execute();
    });
    return dataLogin;
  }
}
