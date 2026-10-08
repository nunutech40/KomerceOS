import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_event.dart';
import 'package:komtim_partner/features/superapp/features/setting/bloc/setting_profile_state.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/setting_profile.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/repositories/setting_profile_repository.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_profile_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/sections/profile_section_fields.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/sections/profile_sections.dart';
import 'package:komtim_partner/DI/injection.dart';

const profile = SettingProfile(
    fullName: 'Partner',
    username: 'partner',
    phone: '081234567890',
    email: 'partner@example.com',
    address: 'Alamat lama',
    gender: ProfileGender.male,
    businessName: 'Toko',
    businessPhone: '081234567890',
    location: ProfileOption(id: '1', label: 'Banyumas'));

const superappProfile = SuperappProfileModel(
  fullName: 'Partner',
  username: 'partner',
  noHp: '081234567890',
  email: 'partner@example.com',
  address: 'Alamat lama',
  gender: 1,
  businessProfile: BusinessProfileModel(
    brandName: 'Toko',
    businessPhone: '081234567890',
    location: 'Banyumas',
  ),
);

void _ignoreProfileText(String _) {}
void _ignoreProfileTap() {}

class MockSuperappProfileBloc
    extends MockBloc<SuperappProfileEvent, SuperappProfileState>
    implements SuperappProfileBloc {}

class FakeSettingProfileRepository implements SettingProfileRepository {
  final bool failUpdate;
  final bool failBusiness;
  final Completer<void>? businessGate;
  int accountUpdates = 0;
  int businessUpdates = 0;
  int refreshNotifications = 0;
  FakeSettingProfileRepository(
      {this.failUpdate = false, this.failBusiness = false, this.businessGate});
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
    if (businessGate != null) await businessGate!.future;
    if (failUpdate || failBusiness) throw Exception('offline');
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
  const refreshed = SuperappProfileModel(
    fullName: 'Partner',
    username: 'partner',
    noHp: '081234567890',
    email: 'partner@example.com',
    gender: 1,
    isKtpVerified: true,
    address: 'Alamat lama',
    businessProfile: BusinessProfileModel(
        brandName: 'Toko fresh',
        businessPhone: '089999999999',
        location: 'Jakarta',
        businessSector: 'Fashion'),
  );

  testWidgets('text fields display updated global values and preserve typing',
      (tester) async {
    Widget form(String value) => MaterialApp(
        home: Scaffold(
            body: ProfileTextField(
                label: 'No. HP Bisnis',
                value: value,
                hint: 'No. HP Bisnis',
                onChanged: (_) {})));
    await tester.pumpWidget(form(''));
    await tester.pumpWidget(form('081234567890'));
    expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '081234567890');
    await tester.enterText(find.byType(TextFormField), '089999999999');
    final controller =
        tester.widget<EditableText>(find.byType(EditableText)).controller;
    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pumpWidget(form('089999999999'));
    expect(controller.selection.baseOffset, 3);
  });

  testWidgets('only name and address are editable in personal profile',
      (tester) async {
    var readOnlyTaps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          SectionName(
            profile: profile,
            onNameChanged: (_) {},
            onReadOnlyTap: () => readOnlyTaps++,
          ),
          SectionContacts(
            profile: profile,
            onTap: () => readOnlyTaps++,
          ),
          SectionAddress(profile: profile, onChanged: (_) {}),
        ]),
      ),
    ));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byKey(const ValueKey('Username')), findsNothing);
    expect(find.byKey(const ValueKey('No. HP')), findsNothing);
    expect(find.byKey(const ValueKey('Email')), findsNothing);
    await tester.tap(find.text('partner').last);
    await tester.tap(find.text('partner@example.com').last);
    expect(readOnlyTaps, 2);
  });

  testWidgets('business required-field messages match Figma', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SectionBusinessInfo(
            profile: SettingProfile(),
            showRequiredErrors: true,
            onNameChanged: _ignoreProfileText,
            onPhoneChanged: _ignoreProfileText,
            onLocationTap: _ignoreProfileTap,
            onSectorTap: _ignoreProfileTap,
          ),
        ),
      ),
    ));
    expect(find.text('Lokasi harus diisi'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('Nama Bisnis')), 'Toko');
    await tester.enterText(find.byKey(const ValueKey('Nama Bisnis')), '');
    await tester.enterText(
        find.byKey(const ValueKey('No. HP Bisnis')), '081234567890');
    await tester.enterText(find.byKey(const ValueKey('No. HP Bisnis')), '');
    await tester.pump();
    expect(find.text('Nama Bisnis harus diisi'), findsOneWidget);
    expect(find.text('No. HP Bisnis harus diisi'), findsOneWidget);
  });

  testWidgets('edit nama, alamat, dan nomor bisnis memicu validasi langsung',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            SectionName(
              profile: profile,
              onNameChanged: _ignoreProfileText,
              onReadOnlyTap: _ignoreProfileTap,
            ),
            SectionAddress(profile: profile, onChanged: _ignoreProfileText),
            SectionBusinessInfo(
              profile: profile,
              onNameChanged: _ignoreProfileText,
              onPhoneChanged: _ignoreProfileText,
              onLocationTap: _ignoreProfileTap,
              onSectorTap: _ignoreProfileTap,
            ),
          ]),
        ),
      ),
    ));
    await tester.enterText(find.byKey(const ValueKey('Nama Lengkap')), 'Nama2');
    await tester.pump();
    expect(
        find.text('Nama harus 3–60 karakter dan hanya huruf'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('Alamat Lengkap')), '');
    await tester.pump();
    expect(find.text('Alamat harus 1–255 karakter'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('No. HP Bisnis')), '123');
    await tester.pump();
    expect(find.text('Masukkan 8–15 digit nomor HP'), findsOneWidget);
  });

  testWidgets('profile save waits for confirmation and Kembali cancels it',
      (tester) async {
    if (locator.isRegistered<SettingProfileBloc>()) {
      locator.unregister<SettingProfileBloc>();
    }
    final repository = FakeSettingProfileRepository();
    locator.registerFactory(() => SettingProfileBloc(repository: repository));
    addTearDown(() {
      if (locator.isRegistered<SettingProfileBloc>()) {
        locator.unregister<SettingProfileBloc>();
      }
    });
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
    await tester.enterText(
        find.byKey(const ValueKey('Nama Lengkap')), 'Partner Baru');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DsButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan Perubahan?'), findsOneWidget);
    expect(repository.accountUpdates, 0);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(repository.accountUpdates, 0);
    await tester.tap(find.widgetWithText(DsButton, 'Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DsButton, 'Simpan Perubahan'));
    await tester.pumpAndSettle();
    expect(repository.accountUpdates, 1);
  });

  testWidgets('menghapus sebagian nama valid mengaktifkan Simpan',
      (tester) async {
    if (locator.isRegistered<SettingProfileBloc>()) {
      locator.unregister<SettingProfileBloc>();
    }
    locator.registerFactory(
        () => SettingProfileBloc(repository: FakeSettingProfileRepository()));
    addTearDown(() {
      if (locator.isRegistered<SettingProfileBloc>()) {
        locator.unregister<SettingProfileBloc>();
      }
    });
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
    await tester.enterText(
        find.byKey(const ValueKey('Nama Lengkap')), 'Partne');
    await tester.pumpAndSettle();
    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Simpan')).state,
      DsButtonState.enabled,
    );
    await tester.enterText(find.byKey(const ValueKey('Nama Lengkap')), 'Pa');
    await tester.pumpAndSettle();
    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Simpan')).state,
      DsButtonState.disabled,
    );
    expect(find.text('Nama Lengkap harus 3–60 karakter dan hanya huruf.'),
        findsOneWidget);
  });

  test('validasi simpan hanya memeriksa field yang diubah', () {
    const original = SettingProfile(
      fullName: 'Partner',
      address: '',
      businessName: 'Toko',
      businessPhone: '081234567890',
      location: ProfileOption(id: '1', label: 'Banyumas'),
    );
    final nameEdit = SettingProfileState(
      original: original,
      draft: original.copyWith(fullName: 'Partne'),
    );
    expect(nameEdit.isAccountDirty, isTrue);
    expect(nameEdit.isBusinessDirty, isFalse);
    expect(nameEdit.canSave, isTrue);

    final invalidName = SettingProfileState(
      original: original,
      draft: original.copyWith(fullName: 'Pa'),
    );
    expect(invalidName.canSave, isFalse);
    expect(invalidName.saveValidationMessage, contains('Nama Lengkap'));

    final addressEdit = SettingProfileState(
      original: original,
      draft: original.copyWith(address: 'Jl. Mawar 1'),
    );
    expect(addressEdit.canSave, isTrue);

    final genderEdit = SettingProfileState(
      original: original,
      draft: original.copyWith(gender: ProfileGender.female),
    );
    expect(genderEdit.canSave, isTrue);

    final invalidPhone = SettingProfileState(
      original: original,
      draft: original.copyWith(businessPhone: 'abc'),
    );
    expect(invalidPhone.canSave, isFalse);
    expect(invalidPhone.saveValidationMessage, contains('No. HP Bisnis'));

    final businessNameEdit = SettingProfileState(
      original: original,
      draft: original.copyWith(businessName: 'Toko Baru'),
    );
    expect(businessNameEdit.canSave, isTrue);

    const incompleteBusiness = SettingProfile(
      fullName: 'Partner',
      businessName: 'Toko',
    );
    final incompleteBusinessEdit = SettingProfileState(
      original: incompleteBusiness,
      draft: incompleteBusiness.copyWith(businessName: 'Toko Baru'),
    );
    expect(incompleteBusinessEdit.canSave, isFalse);
    expect(incompleteBusinessEdit.saveValidationMessage,
        contains('No. HP Bisnis'));

    final logoEdit = SettingProfileState(
      original: original,
      draft: original.copyWith(logoPath: '/tmp/selected-logo.jpg'),
    );
    expect(logoEdit.canSave, isTrue);

    final logoRefresh = SettingProfileState(
      original: original,
      draft: original.copyWith(logoUrl: 'https://example.com/logo.jpg'),
    );
    expect(logoRefresh.isDirty, isFalse);
    expect(logoRefresh.canSave, isFalse);
  });

  test('global refresh syncs business while retaining account edits', () async {
    final bloc = SettingProfileBloc(repository: FakeSettingProfileRepository());
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(fullName: 'Draft Baru'));
    await bloc.stream.firstWhere((s) => s.isDirty);
    bloc.add(const SettingProfileGlobalLoaded(SuperappProfileModel(
      fullName: 'Partner',
      username: 'partner',
      noHp: '081234567890',
      email: 'partner@example.com',
      gender: 1,
      businessProfile: BusinessProfileModel(
          brandName: 'Toko fresh', businessPhone: '089999999999'),
    )));
    await bloc.stream.firstWhere((s) => s.draft.businessName == 'Toko fresh');
    expect(bloc.state.draft.fullName, 'Draft Baru');
    expect(bloc.state.draft.businessPhone, '089999999999');
    await bloc.close();
  });

  test(
      'successful business save drops selected local logo before global refresh',
      () async {
    final repository = FakeSettingProfileRepository();
    final bloc = SettingProfileBloc(repository: repository);
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(logoPath: '/tmp/selected-logo.jpg'));
    await bloc.stream.firstWhere((s) => s.draft.logoPath != null);
    bloc.save();
    await bloc.stream.firstWhere((s) => !s.saving && !s.isDirty);
    expect(repository.businessUpdates, 1);
    expect(repository.refreshNotifications, 1);
    expect(bloc.state.draft.logoPath, isNull);
    expect(bloc.state.logoStatus, BusinessLogoStatus.awaitingRefresh);
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.logoStatus, BusinessLogoStatus.awaitingRefresh);
    bloc.add(const SettingProfileGlobalLoaded(SuperappProfileModel(
      businessProfile: BusinessProfileModel(
        brandName: 'Toko',
        businessPhone: '081234567890',
        location: 'Banyumas',
        businessLogo: 'https://example.com/server-logo.jpg',
      ),
    )));
    await bloc.stream.firstWhere(
        (s) => s.draft.logoUrl == 'https://example.com/server-logo.jpg');
    expect(bloc.state.draft.logoPath, isNull);
    expect(bloc.state.logoStatus, BusinessLogoStatus.ready);
    await bloc.close();
  });

  test('failed logo upload keeps the chosen file and removes loading',
      () async {
    final repository = FakeSettingProfileRepository(failBusiness: true);
    final bloc = SettingProfileBloc(repository: repository);
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(logoPath: '/tmp/selected-logo.jpg'));
    await bloc.stream.firstWhere((s) => s.draft.logoPath != null);
    bloc.save();
    await bloc.stream.firstWhere((s) => !s.saving && s.message != null);
    expect(bloc.state.logoStatus, BusinessLogoStatus.ready);
    expect(bloc.state.draft.logoPath, '/tmp/selected-logo.jpg');
    expect(repository.refreshNotifications, 0);
    await bloc.close();
  });

  test('logo refresh timeout stops loading without showing the old image',
      () async {
    final bloc = SettingProfileBloc(repository: FakeSettingProfileRepository());
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(logoPath: '/tmp/new-logo.jpg'));
    await bloc.stream.firstWhere((s) => s.draft.logoPath != null);
    bloc.save();
    await bloc.stream.firstWhere(
        (s) => !s.saving && s.logoStatus == BusinessLogoStatus.awaitingRefresh);
    bloc.add(const SettingBusinessLogoRefreshTimedOut());
    await bloc.stream
        .firstWhere((s) => s.logoStatus == BusinessLogoStatus.refreshFailed);
    expect(bloc.state.draft.logoPath, isNull);
    await bloc.close();
  });

  testWidgets('only logo shows loading while waiting for the refreshed URL',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SectionBusinessLogo(
          profile: profile.copyWith(logoUrl: 'https://example.com/old.jpg'),
          logoStatus: BusinessLogoStatus.awaitingRefresh,
          onUpload: () {},
        ),
      ),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Bisnis Logo'), findsOneWidget);
    expect(find.text('Unggah'), findsOneWidget);
  });

  testWidgets('saved business logo preview uses the server URL',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SectionBusinessLogo(
          profile: profile.copyWith(logoUrl: 'https://example.com/logo.jpg'),
          onUpload: () {},
        ),
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, 'https://example.com/logo.jpg');
  });

  testWidgets(
      'business form loads global state, refreshes, and reloads on reopen',
      (tester) async {
    if (locator.isRegistered<SettingProfileBloc>()) {
      locator.unregister<SettingProfileBloc>();
    }
    locator.registerFactory(
        () => SettingProfileBloc(repository: FakeSettingProfileRepository()));
    final updates = StreamController<SuperappProfileState>();
    addTearDown(updates.close);
    final globalProfile = MockSuperappProfileBloc();
    whenListen(globalProfile, updates.stream,
        initialState: const SuperappProfileState(
          status: SuperappProfileStatus.loadingWithCache,
          cachedProfile: superappProfile,
        ));
    Widget page() => BlocProvider<SuperappProfileBloc>.value(
          value: globalProfile,
          child: const MaterialApp(home: SettingProfilePage()),
        );
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    expect(find.text('Toko'), findsOneWidget);
    updates.add(const SuperappProfileState(
      status: SuperappProfileStatus.loaded,
      freshProfile: refreshed,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Toko fresh'), findsOneWidget);
    expect(find.text('089999999999'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.text('Fashion'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(page());
    await tester.pumpAndSettle();
    expect(find.text('Toko fresh'), findsOneWidget);
    expect(find.text('089999999999'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('KYC locks personal edits while preserving business edits', () async {
    final bloc = SettingProfileBloc(repository: FakeSettingProfileRepository());
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft
        .copyWith(fullName: 'Draft account', businessName: 'Draft shop'));
    await bloc.stream.firstWhere((s) => s.isDirty);
    bloc.add(const SettingProfileGlobalLoaded(refreshed));
    await bloc.stream.firstWhere((s) =>
        s.draft.businessName == 'Draft shop' &&
        s.original.businessName == 'Toko fresh');
    expect(bloc.state.personalProfileVerified, isTrue);
    expect(bloc.state.draft.fullName, 'Partner');
    expect(bloc.state.draft.businessName, 'Draft shop');
    expect(bloc.state.canSave, true);
    bloc.update(bloc.state.draft.copyWith(
        fullName: 'Allowed Name',
        username: 'forbidden',
        phone: '00000000',
        email: 'forbidden@example.com',
        businessName: 'New shop'));
    await bloc.stream.firstWhere((s) => s.draft.businessName == 'New shop');
    expect(bloc.state.draft.fullName, 'Partner');
    expect(bloc.state.draft.username, 'partner');
    expect(bloc.state.draft.phone, '081234567890');
    expect(bloc.state.draft.email, 'partner@example.com');
    await bloc.close();
  });

  testWidgets('KYC verified mengunci pribadi tetapi edit bisnis aktif',
      (tester) async {
    if (locator.isRegistered<SettingProfileBloc>()) {
      locator.unregister<SettingProfileBloc>();
    }
    locator.registerFactory(
        () => SettingProfileBloc(repository: FakeSettingProfileRepository()));
    addTearDown(() {
      if (locator.isRegistered<SettingProfileBloc>()) {
        locator.unregister<SettingProfileBloc>();
      }
    });
    final globalProfile = MockSuperappProfileBloc();
    whenListen(
      globalProfile,
      const Stream<SuperappProfileState>.empty(),
      initialState: const SuperappProfileState(
        status: SuperappProfileStatus.loaded,
        freshProfile: refreshed,
      ),
    );
    await tester.pumpWidget(BlocProvider<SuperappProfileBloc>.value(
      value: globalProfile,
      child: const MaterialApp(home: SettingProfilePage()),
    ));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DsTextField>(find.byKey(const ValueKey('Nama Lengkap')))
            .enabled,
        isFalse);
    expect(
        tester
            .widget<DsTextField>(find.byKey(const ValueKey('Alamat Lengkap')))
            .enabled,
        isFalse);
    expect(
        tester
            .widget<ProfilePickerField>(find.byWidgetPredicate((widget) =>
                widget is ProfilePickerField &&
                widget.label == 'Jenis Kelamin'))
            .enabled,
        isFalse);
    await tester.enterText(
        find.byKey(const ValueKey('Nama Bisnis')), 'Toko Baru');
    await tester.pumpAndSettle();
    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Simpan')).state,
      DsButtonState.enabled,
    );
  });

  test(
      'partial save commits account and refreshes global; retry only saves business',
      () async {
    final repository = FakeSettingProfileRepository(failBusiness: true);
    final bloc = SettingProfileBloc(repository: repository);
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft
        .copyWith(fullName: 'New account', businessName: 'New shop'));
    await bloc.stream.firstWhere((s) => s.isDirty);
    bloc.save();
    await bloc.stream.firstWhere((s) => !s.saving && s.message != null);
    expect(repository.accountUpdates, 1);
    expect(repository.refreshNotifications, 1);
    expect(bloc.state.isAccountDirty, false);
    expect(bloc.state.isBusinessDirty, true);
    bloc.save();
    await bloc.stream.firstWhere((s) => s.saving);
    await bloc.stream.firstWhere((s) => !s.saving);
    expect(repository.accountUpdates, 1);
    await bloc.close();
  });

  test('global business refresh received during save is applied after save',
      () async {
    final gate = Completer<void>();
    final bloc = SettingProfileBloc(
        repository: FakeSettingProfileRepository(businessGate: gate));
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(businessName: 'New shop'));
    await bloc.stream.firstWhere((s) => s.isDirty);
    bloc.save();
    await bloc.stream.firstWhere((s) => s.saving);
    bloc.add(const SettingProfileGlobalLoaded(refreshed));
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    await bloc.stream
        .firstWhere((s) => s.draft.businessName == 'Toko fresh' && !s.saving);
    expect(bloc.state.draft.businessPhone, '089999999999');
    expect(bloc.state.draft.location?.label, 'Jakarta');
    expect(bloc.state.isDirty, false);
    await bloc.close();
  });

  test('phone validation accepts supported formats and normalizes separators',
      () {
    expect(isValidPhoneNumber('081234567890'), isTrue);
    expect(isValidPhoneNumber('+6281234567890'), isTrue);
    expect(isValidPhoneNumber('0812-345'), isFalse);
    expect(isValidPhoneNumber('nomor-tidak-valid'), isFalse);
    expect(normalizePhoneNumber(' 0812-3456 7890 '), '081234567890');
    expect(normalizePhoneNumber('+62 812-3456-7890'), '+6281234567890');
  });

  test('read-only account phone does not block editable profile save', () {
    const invalidAccountPhone = SettingProfile(
      fullName: 'Partner Baru',
      username: 'partner',
      phone: 'invalid',
      email: 'partner@example.com',
      address: 'Jl. Mawar 2',
    );
    const invalidBusinessPhone = SettingProfile(
      businessName: 'Toko',
      businessPhone: 'invalid',
      location: ProfileOption(id: '1', label: 'Banyumas'),
    );

    expect(invalidAccountPhone.isAccountValid, isTrue);
    expect(invalidBusinessPhone.isBusinessValid, isFalse);
  });

  test('nama dan alamat mengikuti batas acceptance criteria', () {
    expect(isValidProfileName('An'), isFalse);
    expect(isValidProfileName('Ana'), isTrue);
    expect(isValidProfileName('Siti Nurmaliza'), isTrue);
    expect(isValidProfileName('André'), isTrue);
    expect(isValidProfileName('Nama2'), isFalse);
    expect(isValidProfileName('Nama!'), isFalse);
    expect(isValidProfileName('A' * 60), isTrue);
    expect(isValidProfileName('A' * 61), isFalse);
    expect(isValidProfileAddress('  '), isFalse);
    expect(isValidProfileAddress('Jl. Mawar No. 2'), isTrue);
    expect(isValidProfileAddress('A' * 255), isTrue);
    expect(isValidProfileAddress('A' * 256), isFalse);
  });

  test('simpan nonaktif untuk nama atau alamat invalid', () async {
    final bloc = SettingProfileBloc(repository: FakeSettingProfileRepository());
    bloc.add(const SettingProfileGlobalLoaded(superappProfile));
    await bloc.stream.firstWhere((s) => !s.loading);
    bloc.update(bloc.state.draft.copyWith(fullName: 'A'));
    await bloc.stream.firstWhere((s) => s.draft.fullName == 'A');
    expect(bloc.state.canSave, isFalse);
    bloc.update(
        bloc.state.draft.copyWith(fullName: 'Nama Benar', address: ' '));
    await bloc.stream.firstWhere((s) => s.draft.address == ' ');
    expect(bloc.state.canSave, isFalse);
    bloc.update(bloc.state.draft.copyWith(address: 'Alamat baru'));
    await bloc.stream.firstWhere((s) => s.draft.address == 'Alamat baru');
    expect(bloc.state.canSave, isTrue);
    await bloc.close();
  });

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
