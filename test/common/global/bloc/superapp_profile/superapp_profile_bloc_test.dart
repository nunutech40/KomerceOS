import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_bloc.dart';
import 'package:komtim_partner/common/global/bloc/auth/auth_event.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/core/domain/entities/auth_state.dart';
import 'package:komtim_partner/core/domain/entities/login_model.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/mocks/mocks.mocks.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSuperappProfileRepository mockRepository;
  late MockAuthBloc mockAuthBloc;
  late StreamController<void> refreshController;

  const tProfile = SuperappProfileModel(
    id: 1,
    fullName: 'Test User',
    username: 'test',
    saldo: 100000,
    kompoints: 500,
  );

  setUp(() {
    mockRepository = MockSuperappProfileRepository();
    mockAuthBloc = MockAuthBloc();
    refreshController = StreamController<void>.broadcast();

    when(mockRepository.profileShouldRefresh)
        .thenAnswer((_) => refreshController.stream);
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthState.initial(),
    );
  });

  tearDown(() {
    refreshController.close();
  });

  group('SuperappProfileBloc - Preloaded Profile Handshake (1x hit optimization)', () {
    blocTest<SuperappProfileBloc, SuperappProfileState>(
      'emits loaded immediately when usePreloaded: true and preloaded profile exists (0 network call)',
      setUp: () {
        when(mockRepository.consumePendingProfile()).thenReturn(tProfile);
      },
      build: () => SuperappProfileBloc(
        repository: mockRepository,
        authBloc: mockAuthBloc,
      ),
      act: (bloc) => bloc.add(const FetchSuperappProfileEvent(usePreloaded: true)),
      expect: () => [
        const SuperappProfileState(
          status: SuperappProfileStatus.loaded,
          freshProfile: tProfile,
          cachedProfile: tProfile,
          isBalanceLoading: false,
          isBalanceError: false,
          isBackgroundRefresh: false,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(mockRepository.consumePendingProfile()).called(1);
        verifyNever(mockRepository.getProfile());
        verifyNever(mockRepository.getCachedProfile());
      },
    );

    blocTest<SuperappProfileBloc, SuperappProfileState>(
      'falls back to normal network fetch when usePreloaded: true but consumePendingProfile() returns null',
      setUp: () {
        when(mockRepository.consumePendingProfile()).thenReturn(null);
        when(mockRepository.getCachedProfile()).thenAnswer((_) async => null);
        when(mockRepository.getProfile()).thenAnswer((_) async => const Right(tProfile));
      },
      build: () => SuperappProfileBloc(
        repository: mockRepository,
        authBloc: mockAuthBloc,
      ),
      act: (bloc) => bloc.add(const FetchSuperappProfileEvent(usePreloaded: true)),
      expect: () => [
        const SuperappProfileState(
          status: SuperappProfileStatus.loading,
          isBalanceLoading: true,
          isBalanceError: false,
        ),
        const SuperappProfileState(
          status: SuperappProfileStatus.loaded,
          freshProfile: tProfile,
          cachedProfile: tProfile,
          isBalanceLoading: false,
          isBalanceError: false,
          isBackgroundRefresh: false,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verify(mockRepository.consumePendingProfile()).called(1);
        verify(mockRepository.getCachedProfile()).called(1);
        verify(mockRepository.getProfile()).called(1);
      },
    );

    blocTest<SuperappProfileBloc, SuperappProfileState>(
      'normal fetch without usePreloaded bypasses consumePendingProfile entirely',
      setUp: () {
        when(mockRepository.getCachedProfile()).thenAnswer((_) async => null);
        when(mockRepository.getProfile()).thenAnswer((_) async => const Right(tProfile));
      },
      build: () => SuperappProfileBloc(
        repository: mockRepository,
        authBloc: mockAuthBloc,
      ),
      act: (bloc) => bloc.add(const FetchSuperappProfileEvent(usePreloaded: false)),
      expect: () => [
        const SuperappProfileState(
          status: SuperappProfileStatus.loading,
          isBalanceLoading: true,
          isBalanceError: false,
        ),
        const SuperappProfileState(
          status: SuperappProfileStatus.loaded,
          freshProfile: tProfile,
          cachedProfile: tProfile,
          isBalanceLoading: false,
          isBalanceError: false,
          isBackgroundRefresh: false,
          errorMessage: null,
        ),
      ],
      verify: (_) {
        verifyNever(mockRepository.consumePendingProfile());
        verify(mockRepository.getCachedProfile()).called(1);
        verify(mockRepository.getProfile()).called(1);
      },
    );

    test('auto-fetches with usePreloaded: true when AuthBloc emits authenticated', () async {
      final authController = StreamController<AuthState>.broadcast();
      whenListen(
        mockAuthBloc,
        authController.stream,
        initialState: AuthState.initial(),
      );
      when(mockRepository.consumePendingProfile()).thenReturn(tProfile);

      final bloc = SuperappProfileBloc(
        repository: mockRepository,
        authBloc: mockAuthBloc,
      );

      const tUser = UserLoginModel(id: 1, username: 'test', fullName: 'Test', email: 'test@komerce.id');
      authController.add(AuthState.authenticated(tUser));

      await expectLater(
        bloc.stream,
        emits(
          const SuperappProfileState(
            status: SuperappProfileStatus.loaded,
            freshProfile: tProfile,
            cachedProfile: tProfile,
            isBalanceLoading: false,
            isBalanceError: false,
            isBackgroundRefresh: false,
            errorMessage: null,
          ),
        ),
      );

      verify(mockRepository.consumePendingProfile()).called(1);
      verifyNever(mockRepository.getProfile());

      await bloc.close();
      await authController.close();
    });
  });
}

