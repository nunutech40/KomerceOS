import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/change_password_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

void main() {
  late ChangePasswordUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = ChangePasswordUseCase(mockAuthRepository);
  });

  const tOldPass = 'oldPass123';
  const tNewPass = 'newPass123';
  const tConfirmPass = 'newPass123';

  group('ChangePasswordUseCase', () {
    // ----- HAPPY PATH -----
    test('harus mereturn balasan Right(true) dari auth repository (Happy Path)', () async {
      when(mockAuthRepository.changePassword(tOldPass, tNewPass, tConfirmPass)).thenAnswer((_) async => const Right(true));

      final result = await usecase.execute(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Right(true));
      verify(mockAuthRepository.changePassword(tOldPass, tNewPass, tConfirmPass)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // ----- ERROR PATH -----
    test('harus memancarkan (Left) failure murni ketika repository gagal merubah kata sandi (Error Path)', () async {
      when(mockAuthRepository.changePassword(tOldPass, tNewPass, tConfirmPass))
          .thenAnswer((_) async => const Left(ServerFailure('Password Terlalu Lemah')));

      final result = await usecase.execute(tOldPass, tNewPass, tConfirmPass);

      expect(result, const Left(ServerFailure('Password Terlalu Lemah')));
      verify(mockAuthRepository.changePassword(tOldPass, tNewPass, tConfirmPass)).called(1);
    });
  });
}
