import 'dart:async';
import 'dart:convert';

import 'package:komtim_partner/common/constants.dart';
import 'package:komtim_partner/core/data/models/forget_pin_response.dart';
import 'package:komtim_partner/core/data/models/talents_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/token_provider.dart';
import '../../models/login_response.dart';
import '../../models/profile_response.dart';
import 'secure_storage_service.dart';

class SharedPref implements TokenProvider {
  final Future<SharedPreferences> sharedPreferences;
  final SecureStorageService secureStorage;

  SharedPref({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  /// Menyimpan data pengguna dan token login.
  ///
  /// **PENTING:** Token disimpan secara aman di [SecureStorageService],
  /// sedangkan data User disimpan di [SharedPreferences] (tanpa token) untuk keperluan UI.
  Future<void> saveUserAndToken(LoginResponse userAndToken) async {
    final prefs = await sharedPreferences;

    // 1. Simpan Token ke Secure Storage (Aman)
    if (userAndToken.accessToken != null) {
      await secureStorage.saveTokens(
          accessToken: userAndToken.accessToken!,
          refreshToken: ''); // Endpoint ini tidak mengembalikan refresh token
    }

    // 2. Bersihkan token dari objek sebelum disimpan ke SharedPref (Keamanan)
    var userOnly = LoginResponse(
        accessToken: null, // Jangan simpan di prefs
        tokenType: userAndToken.tokenType,
        data: userAndToken.data);

    String userJson = jsonEncode(userOnly.toJson());
    await prefs.setString(USERANDTOKEN, userJson);
  }

  Future<void> updateTokens(String accessToken, String refreshToken) async {
    // Save new tokens to secure storage
    await secureStorage.saveTokens(
        accessToken: accessToken, refreshToken: refreshToken);

    // Not necessary to update SharedPref if we stopped saving tokens there.
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await updateTokens(accessToken, refreshToken);
  }

  Future<bool> saveTime(String time) async {
    final prefs = await sharedPreferences;
    return await prefs.setString(TIME, time);
  }

  Future<bool> deleteTime() async {
    final prefs = await sharedPreferences;
    return await prefs.setString(TIME, "");
  }

  Future<ForgetPinResponse> getTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedList = prefs.getString(TIME);
    final result = ForgetPinResponse(expiredAt: encodedList ?? '');
    return result;
  }

  Future<void> saveFcmToken(String fcmToken) async {
    final prefs = await sharedPreferences;
    await prefs.setString(FCMTOKEN, fcmToken);
  }

  Future<String> getFcmToken() async {
    final prefs = await sharedPreferences;
    return prefs.getString(FCMTOKEN) ?? '';
  }

  Future<void> saveRemoteVersion(String remote) async {
    final prefs = await sharedPreferences;
    await prefs.setString(REMOTEVERSION, remote);
  }

  Future<String> getRemoteVersion() async {
    final prefs = await sharedPreferences;
    return prefs.getString(REMOTEVERSION) ?? '';
  }

  Future<bool> saveTalents(List<TalentsSelectedData> talents) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList =
        talents.map((e) => json.encode(e.toJson())).toList();
    return await prefs.setStringList(DATATALENT, encodedList);
  }

  Future<List<TalentsSelectedData>> getTalents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList = prefs.getStringList(DATATALENT) ?? [];
    List<TalentsSelectedData> objectList = encodedList
        .map((e) => TalentsSelectedData.fromJson(json.decode(e)))
        .toList();
    return objectList;
  }

  Future<bool> updateReasonByJobAssigneeId(
      int? jobAssigneeId, String? newReason, bool? isSelected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList = prefs.getStringList(DATATALENT) ?? [];

    List<TalentsSelectedData> objectList = encodedList
        .map((e) => TalentsSelectedData.fromJson(json.decode(e)))
        .toList();

    for (int i = 0; i < objectList.length; i++) {
      if (objectList[i].jobAssigneeId == jobAssigneeId) {
        TalentsSelectedData updatedTalent = TalentsSelectedData(
          jobAssigneeId: objectList[i].jobAssigneeId,
          talentId: objectList[i].talentId,
          talentName: objectList[i].talentName,
          hiredDate: objectList[i].hiredDate,
          duration: objectList[i].duration,
          isSelected: isSelected ?? true,
          reason: newReason ?? '',
        );

        encodedList[i] = json.encode(updatedTalent.toJson());
        break;
      }
    }

    return await prefs.setStringList(DATATALENT, encodedList);
  }

  Future<void> clearTalents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(DATATALENT);
  }

  Future<void> saveProfileData(ProfileResponse profileData) async {
    final prefs = await sharedPreferences;
    String profileDataJson = jsonEncode(profileData.toJson());
    await prefs.setString(PROFILEDATA, profileDataJson);
  }

  Future<ProfileResponse?> getProfileResponse() async {
    final prefs = await sharedPreferences;
    String? dataProfile = prefs.getString(PROFILEDATA);
    if (dataProfile == null) {
      return null;
    }
    return ProfileResponse.fromJson(jsonDecode(dataProfile));
  }

  /// Menghapus semua data sesi.
  ///
  /// Menghapus data dari [SharedPreferences] dan token dari [SecureStorageService].
  Future<void> removeDataPref() async {
    final prefs = await sharedPreferences;
    await prefs.clear();
    await secureStorage.deleteTokens();
  }

  @override
  Future<void> clearTokens() async {
    await removeDataPref();
  }

  /// Mengambil Access Token dari Secure Storage.
  @override
  Future<String?> getAccessToken() async {
    return getToken();
  }

  /// Mengambil Access Token dari Secure Storage.
  Future<String?> getToken() async {
    // REFACTORED: Baca dari SecureStorage, bukan SharedPref lagi
    return await secureStorage.getAccessToken();
  }

  /// Mengambil Refresh Token dari Secure Storage.
  @override
  Future<String?> getRefreshToken() async {
    // REFACTORED: Baca dari SecureStorage
    return await secureStorage.getRefreshToken();
  }

  /// Memeriksa apakah user sudah login.
  ///
  /// Mengecek keberadaan token di SecureStorage.
  Future<bool> isLoggedIn() async {
    // REFACTORED: Cek SecureStorage
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
