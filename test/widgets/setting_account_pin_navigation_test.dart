import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_account_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/setting_pin_page.dart';

class MockSuperappProfileBloc
    extends MockBloc<SuperappProfileEvent, SuperappProfileState>
    implements SuperappProfileBloc {}

void main() {
  Future<void> pumpAccountPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profileBloc = MockSuperappProfileBloc();
    whenListen(
      profileBloc,
      const Stream<SuperappProfileState>.empty(),
      initialState: const SuperappProfileState(
        status: SuperappProfileStatus.loaded,
        freshProfile: SuperappProfileModel(
          fullName: 'Partner Test',
          email: 'partner@example.com',
        ),
      ),
    );
    await tester.pumpWidget(BlocProvider<SuperappProfileBloc>.value(
      value: profileBloc,
      child: const MaterialApp(home: SettingAccountPage()),
    ));
  }

  testWidgets('akun tanpa PIN masuk ke sheet lalu halaman Buat PIN baru',
      (tester) async {
    await pumpAccountPage(tester);
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu Belum Membuat PIN'), findsOneWidget);
    final titleRect = tester.getRect(find.text('Kamu Belum Membuat PIN'));
    final closeRect = tester.getRect(find.byIcon(Icons.close));
    expect(titleRect.right, lessThan(closeRect.left));
    expect(find.text('Preview alur PIN baru (tanpa API)'), findsNothing);
    await tester.tap(find.text('Buat PIN'));
    await tester.pumpAndSettle();
    expect(find.byType(PinFlowPage), findsOneWidget);
    expect(find.text('Masukkan 6 Digit PIN Baru'), findsOneWidget);
    expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .focusNode
            ?.hasFocus,
        isTrue);
  });

  testWidgets('setelah alur buat selesai, menu PIN bisa dibuka',
      (tester) async {
    await pumpAccountPage(tester);
    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat PIN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pump();
    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PIN'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingPinPage), findsOneWidget);
    expect(find.text('Lupa PIN'), findsOneWidget);
    expect(find.text('Ubah PIN'), findsOneWidget);
  });
}
