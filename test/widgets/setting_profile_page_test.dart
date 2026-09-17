import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/setting_profile.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/repositories/setting_profile_repository.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_profile_page.dart';
import 'package:komtim_partner/DI/injection.dart';

const profile = SettingProfile(
    fullName: 'Partner',
    gender: ProfileGender.male,
    businessName: 'Toko',
    businessPhone: '081234567890',
    location: ProfileOption(id: '1', label: 'Banyumas'));

class FakeSettingProfileRepository implements SettingProfileRepository {
  final bool failUpdate;
  FakeSettingProfileRepository({this.failUpdate = false});
  @override
  Future<SettingProfile> getProfile() async => profile;
  @override
  Future<SettingProfile> updateAccount(SettingProfile value) async {
    if (failUpdate) throw Exception('offline');
    return value;
  }
  @override
  Future<SettingProfile> updateBusiness(SettingProfile value) async {
    if (failUpdate) throw Exception('offline');
    return value;
  }
  @override
  Future<List<ProfileOption>> getBusinessSectors() async => const [];
  @override
  Future<List<ProfileOption>> searchBusinessLocations(String keyword) async =>
      const [];
}

void main() {
  test('save only commits after success; failure retains draft', () async {
    final cubit = SettingProfileBloc(
        repository: FakeSettingProfileRepository(failUpdate: true));
    cubit.update(profile.copyWith(gender: ProfileGender.female));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.canSave, isTrue);
    cubit.save();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.original, profile);
    expect(cubit.state.draft.gender, ProfileGender.female);
    expect(cubit.state.canSave, isTrue);
    await cubit.close();
  });

  test('successful save resets dirty state; missing API does not', () async {
    final cubit = SettingProfileBloc(repository: FakeSettingProfileRepository());
    cubit.update(profile.copyWith(address: 'Alamat baru'));
    await Future<void>.delayed(Duration.zero);
    cubit.save();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isDirty, isFalse);
    await cubit.close();
    final offline = SettingProfileBloc(
        repository: FakeSettingProfileRepository(failUpdate: true));
    offline.update(profile.copyWith(address: 'Alamat baru'));
    await Future<void>.delayed(Duration.zero);
    offline.save();
    await Future<void>.delayed(Duration.zero);
    expect(offline.state.isDirty, isTrue);
    await offline.close();
  });

  testWidgets('gender cancel preserves initial data; apply enables save',
      (tester) async {
    if (locator.isRegistered<SettingProfileBloc>()) {
      locator.unregister<SettingProfileBloc>();
    }
    locator.registerFactory(() => SettingProfileBloc(
        repository: FakeSettingProfileRepository()));
    await tester.pumpWidget(const MaterialApp(home: SettingProfilePage()));
    await tester.pumpAndSettle();
    expect(
        tester.widget<DsButton>(find.widgetWithText(DsButton, 'Simpan')).state,
        DsButtonState.disabled);
    await tester.tap(find.text('Laki-laki').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perempuan'));
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Laki-laki'), findsOneWidget);
    await tester.tap(find.text('Laki-laki').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perempuan'));
    await tester.pump();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    expect(find.text('Perempuan'), findsOneWidget);
    expect(
        tester.widget<DsButton>(find.widgetWithText(DsButton, 'Simpan')).state,
        DsButtonState.enabled);
    expect(tester.takeException(), isNull);
  });
}
