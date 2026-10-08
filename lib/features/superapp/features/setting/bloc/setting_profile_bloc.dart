import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import '../domain/entities/setting_profile.dart';
import '../domain/repositories/setting_profile_repository.dart';
import 'setting_profile_event.dart';
import 'setting_profile_state.dart';

class SettingProfileBloc
    extends Bloc<SettingProfileEvent, SettingProfileState> {
  final SettingProfileRepository repository;
  Timer? _locationDebounce;
  Timer? _logoRefreshTimer;
  String? _logoUrlBeforeUpload;
  SuperappProfileModel? _pendingGlobalProfile;
  SettingProfileBloc({required this.repository})
      : super(const SettingProfileState.initial()) {
    on<SettingProfileFetchRequested>(_onFetch);
    on<SettingProfileGlobalLoaded>(_onGlobalLoaded);
    on<SettingProfileChanged>(_onChanged);
    on<SettingProfileSaveRequested>(_onSaveRequested);
    on<SettingAccountProfileUpdateRequested>(_onAccountUpdate);
    on<SettingBusinessProfileUpdateRequested>(_onBusinessUpdate);
    on<SettingBusinessLogoRefreshTimedOut>(_onLogoRefreshTimedOut);
    on<SettingBusinessSectorsRequested>(_onSectorsRequested);
    on<SettingBusinessLocationsRequested>(_onLocationsRequested);
    on<SettingBusinessLocationsDebounced>(_onLocationsDebounced);
  }

  void _onGlobalLoaded(
      SettingProfileGlobalLoaded event, Emitter<SettingProfileState> emit) {
    final profile = event.profile;
    if (state.saving) {
      _pendingGlobalProfile = profile;
      return;
    }
    _syncGlobalProfile(profile, emit);
  }

  void _syncGlobalProfile(
      SuperappProfileModel profile, Emitter<SettingProfileState> emit) {
    final fresh = SettingProfile.fromGlobalProfile(profile);
    var draft = state.draft.mergeRefresh(fresh, state.original);
    draft = draft.copyWith(
      username: fresh.username,
      phone: fresh.phone,
      email: fresh.email,
    );
    if (profile.isKtpVerified == true) {
      draft = draft.withAccountFrom(fresh);
    }
    final logoChanged = state.logoStatus != BusinessLogoStatus.ready &&
        fresh.logoUrl != null &&
        fresh.logoUrl != _logoUrlBeforeUpload;
    if (logoChanged) {
      _logoRefreshTimer?.cancel();
      _logoUrlBeforeUpload = null;
    }
    emit(state.copyWith(
      original: fresh,
      draft: draft,
      loading: false,
      personalProfileVerified: profile.isKtpVerified == true,
      logoStatus: logoChanged ? BusinessLogoStatus.ready : state.logoStatus,
      message: null,
    ));
  }

  void _startLogoRefreshTimeout() {
    _logoRefreshTimer?.cancel();
    _logoRefreshTimer = Timer(const Duration(seconds: 20),
        () => add(const SettingBusinessLogoRefreshTimedOut()));
  }

  void _onLogoRefreshTimedOut(SettingBusinessLogoRefreshTimedOut event,
      Emitter<SettingProfileState> emit) {
    if (state.logoStatus != BusinessLogoStatus.awaitingRefresh) return;
    emit(state.copyWith(
      logoStatus: BusinessLogoStatus.refreshFailed,
      message: 'Logo tersimpan, tetapi gambar terbaru belum bisa dimuat.',
    ));
  }

  Future<void> _onSectorsRequested(SettingBusinessSectorsRequested event,
      Emitter<SettingProfileState> emit) async {
    if (state.businessSectors.isNotEmpty) return;
    emit(state.copyWith(loadingSectors: true, message: null));
    try {
      final sectors = await repository.getBusinessSectors();
      if (!isClosed) {
        emit(state.copyWith(businessSectors: sectors, loadingSectors: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
            loadingSectors: false, message: 'Gagal memuat sektor bisnis.'));
      }
    }
  }

  void _onLocationsRequested(SettingBusinessLocationsRequested event,
      Emitter<SettingProfileState> emit) {
    _locationDebounce?.cancel();
    emit(state.copyWith(loadingLocations: true, message: null));
    _locationDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) add(SettingBusinessLocationsDebounced(event.keyword));
    });
  }

  Future<void> _onLocationsDebounced(SettingBusinessLocationsDebounced event,
      Emitter<SettingProfileState> emit) async {
    try {
      final locations = await repository.searchBusinessLocations(event.keyword);
      emit(state.copyWith(locations: locations, loadingLocations: false));
    } catch (_) {
      emit(state.copyWith(
          loadingLocations: false, message: 'Gagal memuat lokasi bisnis.'));
    }
  }

  @override
  Future<void> close() {
    _locationDebounce?.cancel();
    _logoRefreshTimer?.cancel();
    return super.close();
  }

  void update(SettingProfile draft) => add(SettingProfileChanged(draft));

  void save() => add(const SettingProfileSaveRequested());

  Future<void> _onFetch(SettingProfileFetchRequested event,
      Emitter<SettingProfileState> emit) async {
    emit(state.copyWith(loading: true, message: null));
    try {
      final profile = await repository.getProfile();
      if (!isClosed) {
        emit(state.copyWith(original: profile, draft: profile, loading: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
            loading: false,
            message: 'Gagal memuat profil. Silakan coba lagi.'));
      }
    }
  }

  void _onChanged(
      SettingProfileChanged event, Emitter<SettingProfileState> emit) {
    if (state.saving || state.loading) return;
    final selectedAnotherLogo = event.draft.logoPath != state.draft.logoPath;
    if (selectedAnotherLogo) {
      _logoRefreshTimer?.cancel();
      _logoUrlBeforeUpload = null;
    }
    final updatedDraft = state.personalProfileVerified
        ? event.draft.withAccountFrom(state.original)
        : event.draft;
    emit(state.copyWith(
        draft: updatedDraft.copyWith(
          username: state.original.username,
          phone: state.original.phone,
          email: state.original.email,
        ),
        logoStatus:
            selectedAnotherLogo ? BusinessLogoStatus.ready : state.logoStatus));
  }

  Future<void> _onSaveRequested(SettingProfileSaveRequested event,
      Emitter<SettingProfileState> emit) async {
    if (!state.canSave) return;
    final draft = state.draft;
    final saveAccount = state.isAccountDirty;
    final saveBusiness = state.isBusinessDirty;
    final uploadingLogo = saveBusiness && draft.logoPath != null;
    if (uploadingLogo) _logoUrlBeforeUpload = state.original.logoUrl;
    var updated = false;
    var logoUploaded = false;
    emit(state.copyWith(
        saving: true,
        logoStatus: uploadingLogo
            ? BusinessLogoStatus.awaitingRefresh
            : state.logoStatus,
        message: null));
    try {
      if (saveAccount) {
        final saved = await repository.updateAccount(draft);
        updated = true;
        if (isClosed) return;
        emit(state.copyWith(
          original: state.original.withAccountFrom(saved),
          draft: state.draft.withAccountFrom(saved),
        ));
      }
      if (saveBusiness) {
        final saved =
            (await repository.updateBusiness(draft)).withoutSelectedLogo();
        updated = true;
        if (uploadingLogo) {
          logoUploaded = true;
          _startLogoRefreshTimeout();
        }
        if (isClosed) return;
        emit(state.copyWith(
          original: state.original.withBusinessFrom(saved),
          draft: state.draft.withBusinessFrom(saved),
        ));
      }
      if (!isClosed) {
        emit(state.copyWith(
            saving: false, message: 'Profil berhasil disimpan.'));
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
            saving: false,
            logoStatus: uploadingLogo && !logoUploaded
                ? BusinessLogoStatus.ready
                : state.logoStatus,
            message: _saveErrorMessage(error)));
      }
    } finally {
      _finishSave(emit, updated);
    }
  }

  Future<void> _onAccountUpdate(SettingAccountProfileUpdateRequested event,
          Emitter<SettingProfileState> emit) =>
      _updateArea(repository.updateAccount, true, emit);

  Future<void> _onBusinessUpdate(SettingBusinessProfileUpdateRequested event,
          Emitter<SettingProfileState> emit) =>
      _updateArea(repository.updateBusiness, false, emit);

  Future<void> _updateArea(
      Future<SettingProfile> Function(SettingProfile) update,
      bool account,
      Emitter<SettingProfileState> emit) async {
    if (state.saving ||
        state.loading ||
        state.saveValidationMessage != null ||
        (account ? !state.isAccountDirty : !state.isBusinessDirty)) {
      return;
    }
    var updated = false;
    final uploadingLogo = !account && state.draft.logoPath != null;
    if (uploadingLogo) _logoUrlBeforeUpload = state.original.logoUrl;
    emit(state.copyWith(
        saving: true,
        savingAccount: account,
        savingBusiness: !account,
        logoStatus: uploadingLogo
            ? BusinessLogoStatus.awaitingRefresh
            : state.logoStatus,
        message: null));
    try {
      final result = await update(state.draft);
      final saved = account ? result : result.withoutSelectedLogo();
      updated = true;
      if (uploadingLogo) _startLogoRefreshTimeout();
      if (!isClosed) {
        emit(state.copyWith(
            original: account
                ? state.original.withAccountFrom(saved)
                : state.original.withBusinessFrom(saved),
            draft: account
                ? state.draft.withAccountFrom(saved)
                : state.draft.withBusinessFrom(saved),
            saving: false,
            savingAccount: false,
            savingBusiness: false,
            message: 'Profil berhasil disimpan.'));
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
            saving: false,
            savingAccount: false,
            savingBusiness: false,
            logoStatus:
                uploadingLogo ? BusinessLogoStatus.ready : state.logoStatus,
            message: _saveErrorMessage(error)));
      }
    } finally {
      _finishSave(emit, updated);
    }
  }

  void _finishSave(Emitter<SettingProfileState> emit, bool updated) {
    final pending = _pendingGlobalProfile;
    _pendingGlobalProfile = null;
    if (!isClosed && pending != null) _syncGlobalProfile(pending, emit);
    // One endpoint may succeed even when the second fails. Global consumers
    // still need to fetch the committed server data in that case.
    if (updated) repository.notifyProfileRefresh();
  }

  String _saveErrorMessage(Object error) {
    if (error is FileSystemException) return error.message;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) return message;
      }
    }
    return 'Gagal menyimpan profil. Silakan coba lagi.';
  }
}
