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
      (profile) {
        final business = profile.businessProfile;
        return SettingProfile(
          fullName: profile.fullName ?? '',
          username: profile.username ?? '',
          phone: profile.noHp ?? '',
          email: profile.email ?? '',
          address: profile.address ?? '',
          gender: profile.gender == 1
              ? ProfileGender.male
              : profile.gender == 2
                  ? ProfileGender.female
                  : null,
          businessName: business?.brandName ?? '',
          businessPhone: business?.businessPhone ?? '',
          location: business?.location == null
              ? null
              : ProfileOption(
                  id: business!.location!, label: business.location!),
          businessSector: business?.businessSector == null
              ? null
              : ProfileOption(
                  id: business!.businessSector!,
                  label: business.businessSector!),
          logoUrl: business?.businessLogo,
        );
      },
    );
  }

  @override
  Future<SettingProfile> updateAccount(SettingProfile profile) async {
    await remote.updateAccount({
      'full_name': profile.fullName,
      'username': profile.username,
      'email': profile.email,
      'no_hp': profile.phone,
      'gender': switch (profile.gender) {
        ProfileGender.male => 1,
        ProfileGender.female => 2,
        null => null,
      },
      'address': profile.address,
    });
    return profile;
  }

  @override
  Future<SettingProfile> updateBusiness(SettingProfile profile) async {
    final data = <String, dynamic>{
      'brand_name': profile.businessName,
      'business_phone': profile.businessPhone,
      'location': profile.location?.label,
      'business_sector': profile.businessSector?.label,
    };
    if (profile.logoPath != null && File(profile.logoPath!).existsSync()) {
      data['business_logo'] = await MultipartFile.fromFile(profile.logoPath!);
    }
    await remote.updateBusiness(data);
    return profile;
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
