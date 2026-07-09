import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/send_forgot_password_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

void main() {
  late SendForgotPasswordUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SendForgotPasswordUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';

  group('SendForgotPasswordUseCase', () {
    // ----- HAPPY PATH -----
    test('harus mereturn balasan Right(true) dari auth repository (Happy Path)', () async {
      when(mockAuthRepository.sendForgotPass(tEmail)).thenAnswer((_) async => const Right(true));

      final result = await usecase.execute(tEmail);

      expect(result, const Right(true));
      verify(mockAuthRepository.sendForgotPass(tEmail)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // ----- ERROR PATH -----
    test('harus memancarkan (Left) failure murni ketika repository gagal request (Error Path)', () async {
      when(mockAuthRepository.sendForgotPass(tEmail)).thenAnswer((_) async => const Left(ServerFailure('Email Not Found')));

      final result = await usecase.execute(tEmail);

      expect(result, const Left(ServerFailure('Email Not Found')));
      verify(mockAuthRepository.sendForgotPass(tEmail)).called(1);
    });
  });
}
