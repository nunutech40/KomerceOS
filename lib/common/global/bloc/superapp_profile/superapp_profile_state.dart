part of 'superapp_profile_bloc.dart';

enum SuperappProfileStatus {
  initial,
  loading,         // loading pertama kali, belum ada cache
  loadingWithCache, // loading API, cache sudah tampil
  loaded,
  error,
}

class SuperappProfileState extends Equatable {
  final SuperappProfileStatus status;

  /// Data dari cache (nama, foto, email — muncul instan)
  final SuperappProfileModel? cachedProfile;

  /// Data fresh dari API (termasuk saldo terkini)
  final SuperappProfileModel? freshProfile;

  /// true = sedang fetch saldo dari API, tampilkan shimmer di area saldo
  final bool isBalanceLoading;

  /// true = fetch gagal saat PERTAMA kali (tampilkan error + retry button)
  final bool isBalanceError;

  /// true = fetch sedang berjalan di background (silent, jangan ganggu UI)
  final bool isBackgroundRefresh;

  final String? errorMessage;

  const SuperappProfileState({
    required this.status,
    this.cachedProfile,
    this.freshProfile,
    this.isBalanceLoading = false,
    this.isBalanceError = false,
    this.isBackgroundRefresh = false,
    this.errorMessage,
  });

  const SuperappProfileState.initial()
      : status = SuperappProfileStatus.initial,
        cachedProfile = null,
        freshProfile = null,
        isBalanceLoading = false,
        isBalanceError = false,
        isBackgroundRefresh = false,
        errorMessage = null;

  /// Saldo yang ditampilkan: dari freshProfile (selalu fresh API), atau null
  int? get displaySaldo => freshProfile?.saldo;

  /// Kompoints dari fresh atau cache
  int? get displayKompoints => freshProfile?.kompoints ?? cachedProfile?.kompoints;

  /// Data profil terbaik yang tersedia (fresh lebih prioritas dari cache)
  SuperappProfileModel? get displayProfile => freshProfile ?? cachedProfile;

  SuperappProfileState copyWith({
    SuperappProfileStatus? status,
    SuperappProfileModel? cachedProfile,
    SuperappProfileModel? freshProfile,
    bool? isBalanceLoading,
    bool? isBalanceError,
    bool? isBackgroundRefresh,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SuperappProfileState(
      status: status ?? this.status,
      cachedProfile: cachedProfile ?? this.cachedProfile,
      freshProfile: freshProfile ?? this.freshProfile,
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      isBalanceError: isBalanceError ?? this.isBalanceError,
      isBackgroundRefresh: isBackgroundRefresh ?? this.isBackgroundRefresh,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        cachedProfile,
        freshProfile,
        isBalanceLoading,
        isBalanceError,
        isBackgroundRefresh,
        errorMessage,
      ];
}
