import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/setting_menu_item.dart';

import '../helpers/helpers.dart';

class MockSuperappProfileBloc
    extends MockBloc<SuperappProfileEvent, SuperappProfileState>
    implements SuperappProfileBloc {}

void main() {
  group('SettingPage Widget Tests', () {
    test('avatar memprioritaskan logo bisnis', () {
      const profile = SuperappProfileModel(
        photoProfileUrl: 'https://example.com/foto-pribadi.jpg',
        businessProfile: BusinessProfileModel(
          businessLogo: 'https://example.com/logo-bisnis.jpg',
        ),
      );
      expect(profile.displayLogoUrl, 'https://example.com/logo-bisnis.jpg');
      expect(
        const SuperappProfileModel(
                photoProfileUrl: 'https://example.com/foto.jpg')
            .displayLogoUrl,
        'https://example.com/foto.jpg',
      );
    });

    testWidgets('Pengaturan memakai logo bisnis dari profil global',
        (tester) async {
      final profileBloc = MockSuperappProfileBloc();
      whenListen(
        profileBloc,
        const Stream<SuperappProfileState>.empty(),
        initialState: const SuperappProfileState(
          status: SuperappProfileStatus.loaded,
          freshProfile: SuperappProfileModel(
            fullName: 'Partner',
            email: 'partner@example.com',
            photoProfileUrl: 'https://example.com/foto-pribadi.jpg',
            businessProfile: BusinessProfileModel(
              businessLogo: 'https://example.com/logo-bisnis.jpg',
            ),
          ),
        ),
      );
      await tester.pumpWidget(BlocProvider<SuperappProfileBloc>.value(
        value: profileBloc,
        child: TestHelper.wrapWithMaterialApp(const SettingPage()),
      ));
      final image = tester.widget<Image>(find.byType(Image).first);
      expect((image.image as NetworkImage).url,
          'https://example.com/logo-bisnis.jpg');
    });

    testWidgets(
        'menampilkan title, profil, dan daftar menu pengaturan dengan benar',
        (WidgetTester tester) async {
      final profileBloc = MockSuperappProfileBloc();
      whenListen(
        profileBloc,
        const Stream<SuperappProfileState>.empty(),
        initialState: const SuperappProfileState(
          status: SuperappProfileStatus.loaded,
          freshProfile: SuperappProfileModel(
            fullName: 'John Doe Assegaf',
            email: 'johndoe@gmail.com',
          ),
        ),
      );
      await tester.pumpWidget(BlocProvider<SuperappProfileBloc>.value(
        value: profileBloc,
        child: TestHelper.wrapWithMaterialApp(const SettingPage()),
      ));

      // Verify page title is rendered
      expect(find.text('Pengaturan'), findsOneWidget);

      // Verify profile section info is rendered
      expect(find.text('John Doe Assegaf'), findsOneWidget);
      expect(find.text('johndoe@gmail.com'), findsOneWidget);

      // Verify all menu items exist by their title text
      expect(find.text('Informasi Akun'), findsOneWidget);
      expect(find.text('Aplikasiku'), findsOneWidget);
      expect(find.text('Tutorial & FAQ'), findsOneWidget);
      expect(find.text('Check for Update'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Verify version number text is rendered
      expect(find.text('V 1.2.0'), findsOneWidget);

      // Verify there are 5 SettingMenuItem widgets
      expect(find.byType(SettingMenuItem), findsNWidgets(5));
    });
  });
}
