import '../../domain/entities/setting_profile.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/repositories/setting_profile_repository.dart';
import '../datasources/setting_profile_remote_datasource.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';

class SettingProfileRepositoryImpl implements SettingProfileRepository {
  final SettingProfileRemoteDataSource remote;
  final SuperappProfileRepository superappProfileRepository;
  SettingProfileRepositoryImpl({
    required this.remote,
    required this.superappProfileRepository,
  });

  @override
  Future<SettingProfile> getProfile() async {
    final result = await superappProfileRepository.getProfile();
    return result.fold(
      (failure) => throw Exception(failure.message),
      SettingProfile.fromGlobalProfile,
    );
  }

  @override
  Future<SettingProfile> updateAccount(SettingProfile profile) async {
    await remote.updateAccount({
      'full_name': profile.fullName,
      'username': profile.username,
      'email': profile.email,
      'no_hp': normalizePhoneNumber(profile.phone),
      'gender': switch (profile.gender) {
        ProfileGender.male => 1,
        ProfileGender.female => 2,
        null => null,
      },
      'address': profile.address,
    });
    return profile.copyWith(phone: normalizePhoneNumber(profile.phone));
  }

  @override
  Future<SettingProfile> updateBusiness(SettingProfile profile) async {
    final fields = <String, dynamic>{
      'brand_name': profile.businessName,
      // These are the fields accepted and persisted by the current auth API.
      'pic_phone': normalizePhoneNumber(profile.businessPhone),
      'business_location': profile.location?.label,
      'partner_category_name': profile.businessSector?.label,
    };
    final imagePath = profile.logoPath;
    if (imagePath != null) {
      if (!await File(imagePath).exists()) {
        throw const FileSystemException(
            'File logo tidak ditemukan. Pilih ulang logo.');
      }
      // The documented `logo` alias binds a file correctly; `business_logo`
      // currently causes the dev API's multipart binder to return HTTP 400.
      fields['logo'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
        contentType: DioMediaType('image', 'jpeg'),
      );
    }
    await remote.updateBusiness(fields);
    return profile.copyWith(
        businessPhone: normalizePhoneNumber(profile.businessPhone));
  }

  @override
  void notifyProfileRefresh() =>
      superappProfileRepository.notifyProfileRefresh();

  @override
  Future<List<ProfileOption>> getBusinessSectors() async =>
      (await remote.getBusinessSectors())
          .map((item) => item.toEntity())
          .toList();

  @override
  Future<List<ProfileOption>> searchBusinessLocations(String keyword) async =>
      (await remote.searchLocations(keyword))
          .map((item) => item.toEntity())
          .toList();
}
