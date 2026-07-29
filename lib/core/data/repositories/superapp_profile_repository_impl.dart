import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/datasources/remote/superapp_profile_remote_datasource.dart';
import 'package:komtim_partner/core/data/models/superapp_profile_response.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Konstanta key untuk cache profile superapp di SharedPreferences
const String _kSuperappProfileCacheKey = 'SUPERAPP_PROFILE_CACHE';

abstract class SuperappProfileRepository {
  /// Fetch profile dari API (saldo selalu fresh)
  Future<Either<Failure, SuperappProfileModel>> getProfile();

  /// Load profile dari cache lokal (saldo = null)
  Future<SuperappProfileModel?> getCachedProfile();

  /// Stream untuk notify semua subscriber agar refresh profile
  /// Dipanggil dari repository lain (topup, dll) setelah transaksi sukses
  Stream<void> get profileShouldRefresh;

  /// Trigger refresh — dipanggil dari repository lain
  void notifyProfileRefresh();

  /// Hapus cache lokal saat logout
  Future<void> clearCache();
}

class SuperappProfileRepositoryImpl implements SuperappProfileRepository {
  final SuperappProfileRemoteDataSource remoteDataSource;
  final Future<SharedPreferences> sharedPreferences;

  final StreamController<void> _refreshController =
      StreamController<void>.broadcast();

  SuperappProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Stream<void> get profileShouldRefresh => _refreshController.stream;

  @override
  void notifyProfileRefresh() {
    if (!_refreshController.isClosed) {
      _refreshController.add(null);
    }
  }

  @override
  Future<Either<Failure, SuperappProfileModel>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      // Cache data statis (tanpa saldo)
      await _saveCache(response);
      return Right(response.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<SuperappProfileModel?> getCachedProfile() async {
    try {
      final prefs = await sharedPreferences;
      final json = prefs.getString(_kSuperappProfileCacheKey);
      if (json == null) return null;
      final response =
          SuperappProfileResponse.fromJsonCache(jsonDecode(json) as Map<String, dynamic>);
      return response.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final prefs = await sharedPreferences;
    await prefs.remove(_kSuperappProfileCacheKey);
  }

  Future<void> _saveCache(SuperappProfileResponse response) async {
    try {
      final prefs = await sharedPreferences;
      await prefs.setString(
          _kSuperappProfileCacheKey, jsonEncode(response.toJsonCache()));
    } catch (_) {
      // Cache gagal tidak boleh crash app
    }
  }
}
