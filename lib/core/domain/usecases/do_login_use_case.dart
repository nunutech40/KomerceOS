import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/login_model.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import '../repositories/auth_repository.dart';

class DoLoginUseCase {
  final AuthRepository repository;
  final AuthBloc authBloc;

  DoLoginUseCase(this.repository, this.authBloc);

  Future<Either<Failure, LoginModel>> execute(String username, String password,
      {String? recaptchaToken}) async {
    final dataLogin = await repository.doLogin(username, password,
        recaptchaToken: recaptchaToken);
    dataLogin.fold((_) {}, (r) {
      if (r.data != null) {
        authBloc.add(AuthLoginRequested(r.data!));
      }
    });
    return dataLogin;
  }
}
