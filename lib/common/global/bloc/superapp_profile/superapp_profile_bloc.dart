import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/global/bloc/auth/auth_bloc.dart';
import '../../../../core/data/repositories/superapp_profile_repository_impl.dart';
import '../../../../core/domain/entities/auth_state.dart';
import '../../../../core/domain/entities/partner_product_model.dart';
import '../../../../core/domain/entities/superapp_profile_model.dart';

part 'superapp_profile_event.dart';
part 'superapp_profile_state.dart';

/// BLoC global singleton untuk profile superapp.
///
/// Reaktif terhadap 3 sumber:
/// 1. AuthBloc.stream — auto-fetch saat authenticated (login / app start)
/// 2. SuperappProfileRepository.profileShouldRefresh — notifikasi dari fitur lain (topup, dll)
/// 3. FetchSuperappProfileEvent — trigger manual jika dibutuhkan
///
/// Bug fixes yang diterapkan:
/// - Timing issue: cek state AuthBloc SAAT INI di constructor (bukan hanya listen stream)
/// - Race condition: pakai `restartable()` — request baru cancel yang lama
/// - Cache stale antar-user: clear cache saat logout (ClearSuperappProfileEvent)
/// - Silent fail saat background refresh: data lama tidak di-reset saat error
class SuperappProfileBloc
    extends Bloc<SuperappProfileEvent, SuperappProfileState> {
  final SuperappProfileRepositoryImpl _repository;
  final AuthBloc _authBloc;

  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<void> _refreshSub;

  SuperappProfileBloc({
    required SuperappProfileRepositoryImpl repository,
    required AuthBloc authBloc,
  })  : _repository = repository,
        _authBloc = authBloc,
        super(const SuperappProfileState.initial()) {
    on<FetchSuperappProfileEvent>(
      _onFetch,
      // restartable(): kalau ada request baru masuk saat yang lama masih berjalan,
      // cancel yang lama dan mulai yang baru → cegah race condition
      transformer: restartable(),
    );
    on<ClearSuperappProfileEvent>(_onClear);

    // Bug fix #1: Timing issue
    // Cek state AuthBloc SEKARANG, bukan hanya menunggu stream.
    // Kalau AuthBloc sudah authenticated sebelum ProfileBloc di-init → tetap fetch.
    if (_authBloc.state.status == AuthStatus.authenticated) {
      add(const FetchSuperappProfileEvent());
    }

    // Bug fix #1 (lanjutan): Subscribe ke stream untuk perubahan berikutnya
    _authSub = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        add(const FetchSuperappProfileEvent());
      } else if (authState.status == AuthStatus.unauthenticated) {
        add(const ClearSuperappProfileEvent());
      }
    });

    // Sumber reaktif #2: Notifikasi dari repository lain (topup sukses, dll)
    _refreshSub = _repository.profileShouldRefresh.listen((_) {
      add(const FetchSuperappProfileEvent());
    });
  }

  Future<void> _onFetch(
    FetchSuperappProfileEvent event,
    Emitter<SuperappProfileState> emit,
  ) async {
    final isFirstLoad = state.cachedProfile == null && state.freshProfile == null;

    if (isFirstLoad) {
      // Load cache dulu agar UI tidak kosong
      final cached = await _repository.getCachedProfile();
      if (cached != null) {
        emit(state.copyWith(
          status: SuperappProfileStatus.loadingWithCache,
          cachedProfile: cached,
          isBalanceLoading: true,
          isBalanceError: false,
        ));
      } else {
        emit(state.copyWith(
          status: SuperappProfileStatus.loading,
          isBalanceLoading: true,
          isBalanceError: false,
        ));
      }
    } else {
      // Ada data sebelumnya → hanya shimmer balance, data lain tetap
      emit(state.copyWith(
        isBalanceLoading: true,
        isBalanceError: false,
        isBackgroundRefresh: true,
      ));
    }

    final result = await _repository.getProfile();

    result.fold(
      (failure) {
        if (isFirstLoad) {
          // Error saat pertama buka → tampilkan error state + tombol retry di UI
          emit(state.copyWith(
            status: SuperappProfileStatus.error,
            errorMessage: failure.message,
            isBalanceLoading: false,
            isBalanceError: true,
          ));
        } else {
          // Bug fix #2: Silent fail saat background refresh
          // Data lama tetap ditampilkan, TIDAK reset balance ke null
          // TIDAK tampilkan snackbar/error (user baru topup, jangan ganggu)
          emit(state.copyWith(
            isBalanceLoading: false,
            isBalanceError: false,  // tidak expose error di UI
            isBackgroundRefresh: false,
          ));
          debugPrint('[SuperappProfileBloc] Background refresh failed silently: ${failure.message}');
        }
      },
      (profile) {
        emit(state.copyWith(
          status: SuperappProfileStatus.loaded,
          freshProfile: profile,
          cachedProfile: profile,
          isBalanceLoading: false,
          isBalanceError: false,
          isBackgroundRefresh: false,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onClear(
    ClearSuperappProfileEvent event,
    Emitter<SuperappProfileState> emit,
  ) async {
    // Bug fix #3: Clear cache saat logout
    // Mencegah user B melihat data user A
    await _repository.clearCache();
    emit(const SuperappProfileState.initial());
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    _refreshSub.cancel();
    return super.close();
  }
}
