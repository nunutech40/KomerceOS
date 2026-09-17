import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/setting_profile.dart';
import '../domain/repositories/setting_profile_repository.dart';
import 'setting_profile_event.dart';
import 'setting_profile_state.dart';

class SettingProfileBloc
    extends Bloc<SettingProfileEvent, SettingProfileState> {
  final SettingProfileRepository repository;
  Timer? _locationDebounce;
  SettingProfileBloc({required this.repository})
      : super(const SettingProfileState.initial()) {
    on<SettingProfileFetchRequested>(_onFetch);
    on<SettingProfileChanged>(_onChanged);
    on<SettingProfileSaveRequested>(_onSaveRequested);
    on<SettingAccountProfileUpdateRequested>(_onAccountUpdate);
    on<SettingBusinessProfileUpdateRequested>(_onBusinessUpdate);
    on<SettingBusinessSectorsRequested>(_onSectorsRequested);
    on<SettingBusinessLocationsRequested>(_onLocationsRequested);
    on<SettingBusinessLocationsDebounced>(_onLocationsDebounced);
    add(const SettingProfileFetchRequested());
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
    emit(state.copyWith(draft: event.draft));
  }

  Future<void> _onSaveRequested(SettingProfileSaveRequested event,
      Emitter<SettingProfileState> emit) async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true, message: null));
    try {
      var saved = state.draft;
      if (_accountChanged) saved = await repository.updateAccount(saved);
      if (_businessChanged) {
        saved = await repository.updateBusiness(state.draft);
      }
      if (!isClosed) {
        emit(state.copyWith(
            original: saved,
            draft: saved,
            saving: false,
            message: 'Profil berhasil disimpan.'));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
            saving: false,
            message: 'Gagal menyimpan profil. Silakan coba lagi.'));
      }
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
    if (state.saving || state.loading) return;
    emit(state.copyWith(
        savingAccount: account, savingBusiness: !account, message: null));
    try {
      final saved = await update(state.draft);
      if (!isClosed) {
        emit(state.copyWith(
            original: saved,
            draft: saved,
            savingAccount: false,
            savingBusiness: false,
            message: 'Profil berhasil disimpan.'));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
            savingAccount: false,
            savingBusiness: false,
            message: 'Gagal menyimpan profil. Silakan coba lagi.'));
      }
    }
  }

  bool get _accountChanged =>
      state.original.fullName != state.draft.fullName ||
      state.original.gender != state.draft.gender ||
      state.original.address != state.draft.address;

  bool get _businessChanged =>
      state.original.businessName != state.draft.businessName ||
      state.original.businessPhone != state.draft.businessPhone ||
      state.original.location != state.draft.location ||
      state.original.businessSector != state.draft.businessSector ||
      state.original.logoPath != state.draft.logoPath;
}
