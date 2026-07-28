import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/usecases/do_login_use_case.dart';
import 'package:komtim_partner/core/domain/entities/login_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:mockito/mockito.dart';

import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';

import '../../../helpers/helpers.dart';

class FakeAuthBloc extends AuthBloc {
  bool loginEventAdded = false;
  UserLoginModel? addedUser;

  FakeAuthBloc({required super.sharedPref});

  @override
  void add(AuthEvent event) {
    if (event is AuthLoginRequested) {
      loginEventAdded = true;
      addedUser = event.user;
    }
    super.add(event);
  }
}

void main() {
  late DoLoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;
  late FakeAuthBloc fakeAuthBloc;
  late MockGetProfileUseCase mockGetProfileUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    fakeAuthBloc = FakeAuthBloc(sharedPref: MockSharedPref());
    mockGetProfileUseCase = MockGetProfileUseCase();
    usecase = DoLoginUseCase(
      mockAuthRepository,
      mockGetProfileUseCase,
      fakeAuthBloc,
    );
  });

  const tUsername = 'john_doe';
  const tPassword = 'secret123';
  
  final tUserLoginModel = UserLoginModel(
    id: 1,
    username: 'john_doe',
    fullName: 'John Doe',
    email: 'john@example.com',
  );

  final tLoginModel = LoginModel(
    accessToken: 'token123',
    tokenType: 'Bearer',
    data: tUserLoginModel,
  );

  group('DoLoginUseCase', () {
    // ----- HAPPY PATH -----
    test('harus merespon Right(tLoginModel) dan mengeksekusi semua orkestrasi manager saat sukses (Happy Path)', () async {
      // Arrange
      when(mockAuthRepository.doLogin(tUsername, tPassword)).thenAnswer((_) async => Right(tLoginModel));
      
      // Setup mock ProfileModel untuk getProfileUseCase
      final tProfileModel = ProfileModel(partnerId: 10);
      when(mockGetProfileUseCase.execute()).thenAnswer((_) async => Right(tProfileModel)); 

      // Act
      final result = await usecase.execute(tUsername, tPassword);

      // Assert
      expect(result, Right(tLoginModel));
      
      // Contract Check ketat (1x masing2)
      verify(mockAuthRepository.doLogin(tUsername, tPassword)).called(1);
      expect(fakeAuthBloc.loginEventAdded, true); 
      expect(fakeAuthBloc.addedUser, tUserLoginModel); 
      verify(mockGetProfileUseCase.execute()).called(1); // profile usecase ikut ditarik
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // ----- ERROR PATH -----
    test('harus mereturn Left(Failure) dari repository tanpa mengeksekusi satupun orkestrasi manager (Error Path)', () async {
      // Arrange
      when(mockAuthRepository.doLogin(tUsername, tPassword)).thenAnswer((_) async => const Left(ServerFailure('Invalid pass')));

      // Act
      final result = await usecase.execute(tUsername, tPassword);

      // Assert
      expect(result, const Left(ServerFailure('Invalid pass')));

      // Contract
      verify(mockAuthRepository.doLogin(tUsername, tPassword)).called(1);

      // EDGE: Pastikan Usecase tidak membocorkan credential manager!
      expect(fakeAuthBloc.loginEventAdded, false);
      verifyZeroInteractions(mockGetProfileUseCase);
    });

    // ----- EDGE PATH -----
    test('harus tetap aman apabila response login repository memiliki parameter data == null (Edge Path)', () async {
      final tLoginModelMismatched = LoginModel(
        accessToken: 'token123',
        tokenType: 'Bearer',
        data: null, // Data null, bayangkan bug parsing
      );
      when(mockAuthRepository.doLogin(tUsername, tPassword)).thenAnswer((_) async => Right(tLoginModelMismatched));
      
      final tProfileModel = ProfileModel(partnerId: 10);
      when(mockGetProfileUseCase.execute()).thenAnswer((_) async => Right(tProfileModel)); 

      final result = await usecase.execute(tUsername, tPassword);

      expect(result, Right(tLoginModelMismatched));
      verify(mockAuthRepository.doLogin(tUsername, tPassword)).called(1);
      
      // Data null -> authenticationManager login tidak boleh dieksekusi! (Menghindari TypeError)
      expect(fakeAuthBloc.loginEventAdded, false);
      
      // Namun Profile usecase tetap ditarik (sesuai implementation `if (r.data != null) ... await getProfileUseCase()`)
      verify(mockGetProfileUseCase.execute()).called(1);
    });
  });
}
