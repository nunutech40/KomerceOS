import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/setting_profile.dart';

void main() {
  const complete = SuperappProfileModel(
    fullName: 'Siti Nurmaliza',
    username: 'siti',
    noHp: '08123456789',
    email: 'siti@example.com',
    gender: 2,
    address: 'Jalan Melati 1',
  );

  test('profil global lengkap mengizinkan tambah rekening', () {
    expect(SettingProfile.fromGlobalProfile(complete).isCompleteForBankAccount,
        isTrue);
  });

  test('setiap field wajib terisi, spasi saja tidak dianggap lengkap', () {
    for (final profile in [
      const SuperappProfileModel(
          username: 'siti',
          noHp: '08123456789',
          email: 'siti@example.com',
          gender: 2,
          address: 'Jalan Melati 1'),
      const SuperappProfileModel(
          fullName: 'Siti',
          noHp: '08123456789',
          email: 'siti@example.com',
          gender: 2,
          address: 'Jalan Melati 1'),
      const SuperappProfileModel(
          fullName: 'Siti',
          username: 'siti',
          email: 'siti@example.com',
          gender: 2,
          address: 'Jalan Melati 1'),
      const SuperappProfileModel(
          fullName: 'Siti',
          username: 'siti',
          noHp: '08123456789',
          gender: 2,
          address: 'Jalan Melati 1'),
      const SuperappProfileModel(
          fullName: 'Siti',
          username: 'siti',
          noHp: '08123456789',
          email: 'siti@example.com',
          address: 'Jalan Melati 1'),
      const SuperappProfileModel(
          fullName: 'Siti',
          username: 'siti',
          noHp: '08123456789',
          email: 'siti@example.com',
          gender: 2,
          address: '   '),
    ]) {
      expect(SettingProfile.fromGlobalProfile(profile).isCompleteForBankAccount,
          isFalse);
    }
  });
}
