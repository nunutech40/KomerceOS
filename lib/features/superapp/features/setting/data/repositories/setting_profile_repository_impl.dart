import '../../domain/entities/setting_profile.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/repositories/setting_profile_repository.dart';
import '../datasources/setting_profile_remote_datasource.dart';

class SettingProfileRepositoryImpl implements SettingProfileRepository {
  final SettingProfileRemoteDataSource remote;
  SettingProfileRepositoryImpl({required this.remote});

  @override
  Future<SettingProfile> getProfile() async {
    return (await remote.getProfile()).toEntity();
  }

  @override
  Future<SettingProfile> updateAccount(SettingProfile profile) async {
    await remote.updateAccount({
      'name': profile.fullName,
      'gender': switch (profile.gender) {
        ProfileGender.male => 1,
        ProfileGender.female => 2,
        null => null,
      },
      'address': profile.address
    });
    return getProfile();
  }

  @override
  Future<SettingProfile> updateBusiness(SettingProfile profile) async {
    final data = <String, dynamic>{
      'brand_name': profile.businessName,
      'no_hp_business': profile.businessPhone,
      'city_code': profile.location?.id,
      'partner_category_name': profile.businessSector?.label,
    };
    if (profile.logoPath != null && File(profile.logoPath!).existsSync()) {
      data['brand_logo'] = await MultipartFile.fromFile(profile.logoPath!);
    }
    await remote.updateBusiness(data);
    return getProfile();
  }

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
