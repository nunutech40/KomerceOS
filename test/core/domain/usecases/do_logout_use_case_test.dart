import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/do_logout_use_case.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/helpers.dart';

void main() {
  late DoLogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;
  late MockAuthenticationManager mockAuthManager;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockAuthManager = MockAuthenticationManager();
    usecase = DoLogoutUseCase(mockAuthRepository, mockAuthManager);
    when(mockAuthManager.logout()).thenAnswer((_) async {});
  });

  group('DoLogoutUseCase', () {
    // ----- HAPPY PATH -----
    test('harus mereturn Right() dari auth repository dan tetap memanggil logout di AuthManager saat login sukses (Happy Path)', () async {
      when(mockAuthRepository.doLogout()).thenAnswer((_) async => const Right(true));

      final result = await usecase.execute();

      expect(result, const Right(true));
      
      // Contract: Repo Dipanggil
      verify(mockAuthRepository.doLogout()).called(1);
      
      // Contract: Auth Manager juga di update agar app state berubah out
      verify(mockAuthManager.logout()).called(1);
    });

    // ----- EDGE PATH -----
    // Menguji termometer bug terhadap kode implementasi "authenticationManager.logout()". Tuntutan kita adalah 
    // mau bagaimanapun api servernya, authentication manager harus tetap memutus state agar app user mental menuju halaman login
    test('harus mereturn Left(Failure) namun TETAP memanggil logout AuthManager agar App membersihkan state, sekalipun Exception (Edge Path)', () async {
      when(mockAuthRepository.doLogout()).thenAnswer((_) async => const Left(ConnectionFailure('Timeout')));

      final result = await usecase.execute();

      expect(result, const Left(ConnectionFailure('Timeout')));
      verify(mockAuthRepository.doLogout()).called(1);

      // Harus Tereksekusi (Clean Up Safety side-effect)! 
      verify(mockAuthManager.logout()).called(1);
    });
  });
}
