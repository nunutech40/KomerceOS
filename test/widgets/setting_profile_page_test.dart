import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_event.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/setting_profile.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/repositories/setting_profile_repository.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_profile_page.dart';
import 'package:komtim_partner/DI/injection.dart';

const profile = SettingProfile(
    fullName: 'Partner',
    username: 'partner',
    phone: '081234567890',
    email: 'partner@example.com',
    gender: ProfileGender.male,
    businessName: 'Toko',
    businessPhone: '081234567890',
    location: ProfileOption(id: '1', label: 'Banyumas'));

const superappProfile = SuperappProfileModel(
  fullName: 'Partner',
  username: 'partner',
  noHp: '081234567890',
  email: 'partner@example.com',
  gender: 1,
  businessProfile: BusinessProfileModel(
    brandName: 'Toko',
    businessPhone: '081234567890',
    location: 'Banyumas',
  ),
);

class MockSuperappProfileBloc
    extends MockBloc<SuperappProfileEvent, SuperappProfileState>
    implements SuperappProfileBloc {}

class FakeSettingProfileRepository implements SettingProfileRepository {
  final bool failUpdate;
  int accountUpdates = 0;
  int businessUpdates = 0;
  int refreshNotifications = 0;
  FakeSettingProfileRepository({this.failUpdate = false});
  @override
  Future<SettingProfile> getProfile() async => profile;
  @override
  Future<SettingProfile> updateAccount(SettingProfile value) async {
    if (failUpdate) throw Exception('offline');
    accountUpdates++;
    return value;
  }

  @override
  Future<SettingProfile> updateBusiness(SettingProfile value) async {
    if (failUpdate) throw Exception('offline');
    businessUpdates++;
    return value;
  }

  @override
  Future<List<ProfileOption>> getBusinessSectors() async => const [];
  @override
  Future<List<ProfileOption>> searchBusinessLocations(String keyword) async =>
      const [];
  @override
  void notifyProfileRefresh() => refreshNotifications++;
}

void main() {
  test('global refresh does not overwrite an unsaved draft', () async {
    final bloc = SettingProfileBloc(repository: FakeSettingProfileRepository());
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.update(bloc.state.draft.copyWith(fullName: 'Draft Baru'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    bloc.add(const SettingProfileGlobalLoaded(
      SuperappProfileModel(fullName: 'Data Refresh'),
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.draft.fullName, 'Draft Baru');
    await bloc.close();
  });

  test('saving account and business triggers one global refresh', () async {
    final repository = FakeSettingProfileRepository();
    final bloc = SettingProfileBloc(repository: repository);
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.update(bloc.state.draft.copyWith(
      fullName: 'Partner Baru',
      businessName: 'Toko Baru',
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    bloc.save();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(repository.accountUpdates, 1);
    expect(repository.businessUpdates, 1);
    expect(repository.refreshNotifications, 1);
    await bloc.close();
  });

  test('save only commits after success; failure retains draft', () async {
    final cubit = SettingProfileBloc(
        repository: FakeSettingProfileRepository(failUpdate: true));
    cubit.add(const SettingProfileFetchRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    cubit.update(profile.copyWith(gender: ProfileGender.female));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.canSave, isTrue);
    cubit.save();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.original, profile);
    expect(cubit.state.draft.gender, ProfileGender.female);
    expect(cubit.state.canSave, isTrue);
    await cubit.close();
  });

  test('successful save resets dirty state; missing API does not', () async {
    final cubit =
        SettingProfileBloc(repository: FakeSettingProfileRepository());
    cubit.add(const SettingProfileFetchRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    cubit.update(profile.copyWith(address: 'Alamat baru'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    cubit.save();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.isDirty, isFalse);
    await cubit.close();
    final offline = SettingProfileBloc(
        repository: FakeSettingProfileRepository(failUpdate: true));
    offline.add(const SettingProfileFetchRequested());
    await Future<void>.delayed(Duration.zero);
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
    locator.registerFactory(
        () => SettingProfileBloc(repository: FakeSettingProfileRepository()));
    final globalProfile = MockSuperappProfileBloc();
    whenListen(
      globalProfile,
      const Stream<SuperappProfileState>.empty(),
      initialState: const SuperappProfileState(
        status: SuperappProfileStatus.loaded,
        freshProfile: superappProfile,
      ),
    );
    await tester.pumpWidget(BlocProvider<SuperappProfileBloc>.value(
      value: globalProfile,
      child: const MaterialApp(home: SettingProfilePage()),
    ));
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
