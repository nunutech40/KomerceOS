import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import path dengan struktur foldermu
import 'package:komtim_partner/common/global/design_system/components/ds_email_field.dart';

void main() {
  group('DsEmailInput Component Tests', () {
    
    // Helper untuk membungkus widget agar bisa di-render
    Widget buildTestableWidget(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget,
          ),
        ),
      );
    }

    testWidgets('Harus menampilkan label dan hint text default dengan benar', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsEmailInput(
            label: 'Alamat Email',
            controller: controller,
          ),
        ),
      );

      // Verifikasi label dirender dengan benar
      expect(find.text('Alamat Email'), findsOneWidget);
      
      // Verifikasi default hint text dirender
      expect(find.text('Masukkan email...'), findsOneWidget);
    });

    testWidgets('Harus menggunakan hintText custom jika diberikan oleh parent', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsEmailInput(
            label: 'Email Alternatif',
            controller: controller,
            hintText: 'Contoh: admin@perusahaan.com',
          ),
        ),
      );

      // Verifikasi hint text custom muncul menggantikan default
      expect(find.text('Contoh: admin@perusahaan.com'), findsOneWidget);
      expect(find.text('Masukkan email...'), findsNothing);
    });

    testWidgets('Input teks harus mengubah nilai controller dan memicu onChanged', (WidgetTester tester) async {
      final controller = TextEditingController();
      String capturedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          DsEmailInput(
            label: 'Email',
            controller: controller,
            onChanged: (value) {
              capturedValue = value;
            },
          ),
        ),
      );

      // Simulasi user mengetik email
      await tester.enterText(find.byType(TextField), 'halo@domain.com');
      await tester.pump();

      // Verifikasi controller.text terupdate
      expect(controller.text, 'halo@domain.com');
      
      // Verifikasi callback onChanged menangkap string yang sama
      expect(capturedValue, 'halo@domain.com');
    });

    testWidgets('Harus menampilkan teks error saat parameter errorText diisi', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsEmailInput(
            label: 'Email',
            controller: controller,
            errorText: 'Format email tidak sesuai standar',
          ),
        ),
      );

      // Verifikasi bahwa pesan error dimunculkan di UI
      expect(find.text('Format email tidak sesuai standar'), findsOneWidget);
    });

    testWidgets('TIDAK boleh merender teks error jika errorText null atau kosong', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsEmailInput(
            label: 'Email',
            controller: controller,
            // errorText tidak di-pass (null)
          ),
        ),
      );

      // Pastikan tidak ada widget Text dengan warna merah yang merupakan error
      // Karena kita tidak tahu persis teks error apa yang mungkin muncul, 
      // kita pastikan state UI error tidak aktif.
      // Cara paling aman di sini adalah memastikan tidak ada child Column ke-3.
      final columnFinder = find.byType(Column);
      final columnWidget = tester.widget<Column>(columnFinder.first);
      
      // Berdasarkan kode kita: anak ke-1 Text(label), ke-2 SizedBox, ke-3 TextField
      // Jika tidak ada error, children.length harus 3.
      expect(columnWidget.children.length, 3);
    });
  });
}