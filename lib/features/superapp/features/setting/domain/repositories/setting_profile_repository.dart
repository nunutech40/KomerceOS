import '../entities/setting_profile.dart';

/// One read contract, with independent write contracts for each profile area.
/// API models can be introduced behind this interface when the contract is ready.
abstract class SettingProfileRepository {
  Future<SettingProfile> getProfile();
  Future<SettingProfile> updateAccount(SettingProfile profile);
  Future<SettingProfile> updateBusiness(SettingProfile profile);
  Future<List<ProfileOption>> getBusinessSectors();
  Future<List<ProfileOption>> searchBusinessLocations(String keyword);
}
