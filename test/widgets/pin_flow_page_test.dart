import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_button.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';

void main() {
  Future<void> showFlow(WidgetTester tester, PinFlow flow) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: PinFlowPage(flow: flow, email: 'partner@example.com'),
    ));
  }

  testWidgets('buat PIN: input, konfirmasi tidak sama, lalu sukses',
      (tester) async {
    await showFlow(tester, PinFlow.create);
    expect(find.text('Masukkan 6 Digit PIN Baru'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pumpAndSettle();
    expect(find.text('Masukkan Ulang PIN Baru'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '111111');
    await tester.pump();
    expect(find.text('PIN yang kamu masukkan salah'), findsOneWidget);
    expect(tester.widget<DsButton>(find.byType(DsButton)).state,
        DsButtonState.disabled);
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pump();
    expect(find.text('PIN yang kamu masukkan salah'), findsNothing);
    expect(tester.widget<DsButton>(find.byType(DsButton)).state,
        DsButtonState.enabled);
    await tester.tap(find.text('Konfirmasi'));
    await tester.pump();
    expect(find.text('Memverifikasi PIN...'), findsOneWidget);
    expect(tester.widget<DsButton>(find.byType(DsButton)).state,
        DsButtonState.loading);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('PIN Kamu Berhasil Dibuat'), findsOneWidget);
  });

  testWidgets('ubah PIN meminta PIN lama sebelum PIN baru', (tester) async {
    await showFlow(tester, PinFlow.change);
    expect(find.text('Masukkan 6 Digit PIN Kamu'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();
    expect(find.text('Masukkan 6 Digit PIN Baru'), findsOneWidget);
    expect(find.text('Ubah PIN'), findsOneWidget);
    expect(
        find.text(
            'Gunakan PIN 6 digit yang berbeda dari PIN sebelumnya dan mudah kamu ingat.'),
        findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    expect(find.text('PIN baru tidak boleh sama dengan PIN sebelumnya'),
        findsOneWidget);
    expect(find.text('Masukkan Ulang PIN Baru'), findsNothing);
  });

  testWidgets('PIN lama salah dua kali lalu dibatasi pada kesalahan ketiga',
      (tester) async {
    await showFlow(tester, PinFlow.change);
    for (var i = 1; i <= 2; i++) {
      await tester.enterText(find.byType(TextField).first, '00000$i');
      await tester.pump();
      expect(
          find.text('PIN salah. Kamu memiliki ${3 - i} percobaan lagi '
              'sebelum akun kamu logout secara otomatis'),
          findsOneWidget);
    }
    await tester.enterText(find.byType(TextField).first, '000003');
    await tester.pumpAndSettle();
    expect(find.text('Terlalu Banyak Percobaan PIN'), findsOneWidget);
    expect(
        find.text('Kamu telah mencapai batas maksimal percobaan PIN. '
            'Demi keamanan akun, silakan coba kembali dalam 24 jam.'),
        findsOneWidget);
  });

  testWidgets('lupa PIN dari input PIN lama berpindah ke OTP dan Buat PIN',
      (tester) async {
    await showFlow(tester, PinFlow.change);
    await tester.tap(find.text('Lupa PIN?'));
    await tester.pump();
    expect(find.text('Pilih Metode Verifikasi'), findsOneWidget);
    await tester.tap(find.text('Kirim OTP'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('Verifikasi'));
    await tester.pump();
    expect(find.text('Masukkan 6 Digit PIN Baru'), findsOneWidget);
    expect(find.text('Buat PIN'), findsOneWidget);
  });

  testWidgets('lupa PIN menahan Kirim Ulang selama cooldown', (tester) async {
    await showFlow(tester, PinFlow.forgot);
    expect(find.text('Pilih Metode Verifikasi'), findsOneWidget);
    await tester.tap(find.text('Kirim OTP'));
    await tester.pump();
    expect(find.text('Masukkan Kode OTP'), findsOneWidget);
    expect(find.text('Kirim Ulang (60 detik)'), findsOneWidget);
    final resend = tester.widget<TextButton>(find.widgetWithText(
      TextButton,
      'Kirim Ulang (60 detik)',
    ));
    expect(resend.onPressed, isNull);
  });

  testWidgets('lima OTP salah menampilkan batas percobaan', (tester) async {
    await showFlow(tester, PinFlow.forgot);
    await tester.tap(find.text('Kirim OTP'));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.enterText(find.byType(TextField).first, '00000$i');
      await tester.pump();
      if (i < 4) {
        expect(find.text('OTP yang kamu masukkan salah'), findsOneWidget);
        expect(tester.widget<DsButton>(find.byType(DsButton)).state,
            DsButtonState.disabled);
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('Terlalu Banyak Percobaan PIN'), findsOneWidget);
  });

  testWidgets('cooldown OTP bertambah hanya setelah Kirim Ulang',
      (tester) async {
    await showFlow(tester, PinFlow.forgot);
    await tester.tap(find.text('Kirim OTP'));
    await tester.pump();
    expect(find.text('Kirim Ulang (60 detik)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.pump();
    expect(find.text('Kirim Ulang (60 detik)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 60));
    expect(find.text('Kirim Ulang'), findsOneWidget);
    await tester.tap(find.text('Kirim Ulang'));
    await tester.pump();
    expect(find.text('Kirim Ulang (120 detik)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '000001');
    await tester.pump();
    expect(find.text('Kirim Ulang (120 detik)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 120));
    await tester.tap(find.text('Kirim Ulang'));
    await tester.pump();
    expect(find.text('Kirim Ulang (240 detik)'), findsOneWidget);
  });

  testWidgets('OTP valid mengaktifkan Verifikasi dan alur Ubah PIN selesai',
      (tester) async {
    await showFlow(tester, PinFlow.change);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '654321');
    await tester.pump();
    await tester.tap(find.text('Konfirmasi'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('PIN Kamu Berhasil Diubah'), findsOneWidget);
  });

  testWidgets('OTP salah langsung error, setelah diedit error hilang',
      (tester) async {
    await showFlow(tester, PinFlow.forgot);
    await tester.tap(find.text('Kirim OTP'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.pump();
    expect(find.text('OTP yang kamu masukkan salah'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    expect(find.text('OTP yang kamu masukkan salah'), findsNothing);
    expect(tester.widget<DsButton>(find.byType(DsButton)).state,
        DsButtonState.enabled);
  });
}
