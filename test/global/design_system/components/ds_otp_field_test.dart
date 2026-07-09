import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import path dengan struktur foldermu
import 'package:komtim_partner/common/global/design_system/components/ds_otp_field.dart';

void main() {
  group('DsOtpField Component Tests', () {
    
    Widget buildTestableWidget(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: widget),
        ),
      );
    }

    testWidgets('State Default: Harus merender 6 kotak input dan divider', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DsOtpField(),
        ),
      );

      // Verifikasi terdapat 6 TextField yang melambangkan 6 digit OTP
      expect(find.byType(TextField), findsNWidgets(6));
      
      // Verifikasi divider (pemisah 3-3) dirender
      expect(find.byType(Divider), findsOneWidget);
      
      // Verifikasi tidak ada error di awal
      expect(find.text('OTP Salah'), findsNothing);
    });

    testWidgets('Visual Error: Harus menampilkan pesan errorText jika parameter diisi', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DsOtpField(
            errorText: 'Kode OTP tidak valid',
          ),
        ),
      );

      // Verifikasi pesan error muncul
      expect(find.text('Kode OTP tidak valid'), findsOneWidget);
    });

    testWidgets('Interaksi Input: Ketikan harus berpindah fokus dan memicu onChanged & onCompleted', (WidgetTester tester) async {
      String lastChangedValue = '';
      String completedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          DsOtpField(
            onChanged: (val) => lastChangedValue = val,
            onCompleted: (val) => completedValue = val,
          ),
        ),
      );

      // Cari semua TextField
      final textFields = find.byType(TextField);

      // Simulasi user mengetik angka 1 sampai 6 di masing-masing kotak
      await tester.enterText(textFields.at(0), '1');
      await tester.pump();
      expect(lastChangedValue, '1'); // onChanged terpanggil

      await tester.enterText(textFields.at(1), '2');
      await tester.pump();
      expect(lastChangedValue, '12');

      // Lewati angka 3, 4, 5 untuk menghemat baris tes, langsung ke 6
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');
      await tester.enterText(textFields.at(4), '5');
      await tester.enterText(textFields.at(5), '6');
      await tester.pump();

      // Verifikasi hasil akhir
      expect(lastChangedValue, '123456');
      expect(completedValue, '123456'); // onCompleted harus terpanggil karena sudah 6 digit
    });

    testWidgets('Interaksi Paste: Paste 6 digit harus otomatis terdistribusi ke semua kotak', (WidgetTester tester) async {
      String completedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          DsOtpField(
            onCompleted: (val) => completedValue = val,
          ),
        ),
      );

      // Simulasi user mem-paste 6 digit string ke kotak pertama
      await tester.enterText(find.byType(TextField).first, '987654');
      await tester.pump();

      // Verifikasi string terdistribusi dan memicu onCompleted
      expect(completedValue, '987654');
      
      // Verifikasi kotak terakhir memegang angka '4'
      final lastTextField = tester.widget<TextField>(find.byType(TextField).last);
      expect(lastTextField.controller?.text, '4');
    });

    testWidgets('Interaksi Backspace: Harus menghapus kotak sebelumnya dan mundur', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DsOtpField(),
        ),
      );

      final textFields = find.byType(TextField);

      // Isi kotak 1 dan 2
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();

      // Fokuskan pada kotak ke-2, lalu kosongkan (seperti menekan backspace sekali)
      await tester.enterText(textFields.at(1), '');
      await tester.pump();

      // Kirim event logical keyboard 'Backspace' saat fokus masih di kotak ke-2 yang kosong
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // Verifikasi bahwa kotak ke-1 (index 0) sekarang ikut kosong akibat retreat backspace
      final firstTextField = tester.widget<TextField>(textFields.at(0));
      expect(firstTextField.controller?.text, isEmpty);
    });

    testWidgets('Sinkronisasi Parent (Controlled State): Clear controller dari luar harus mengosongkan semua kotak', (WidgetTester tester) async {
      final parentController = TextEditingController(text: '123456');

      await tester.pumpWidget(
        buildTestableWidget(
          DsOtpField(
            controller: parentController,
          ),
        ),
      );

      // Pastikan data inisial dari parent masuk ke anak (kotak pertama harus '1')
      var firstTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(firstTextField.controller?.text, '1');

      // AKSI: Parent membersihkan input (seperti klik tombol "Kirim Ulang OTP")
      parentController.clear();
      await tester.pump(); // Wajib pump agar sinkronisasi terjadi

      // Verifikasi bahwa kotak di dalam DsOtpField ikut kosong
      firstTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(firstTextField.controller?.text, isEmpty);
    });
  });
}