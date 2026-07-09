import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import path dengan struktur foldermu
import 'package:komtim_partner/common/global/design_system/components/ds_password_field.dart';

void main() {
  group('DsPasswordField Component Tests', () {
    
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

    testWidgets('State Default: Harus merender label, hint, dan teks dalam keadaan tersembunyi (obscured)', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsPasswordField(
            label: 'Kata Sandi',
            controller: controller,
          ),
        ),
      );

      // Verifikasi label dan hint default
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Masukkan password...'), findsOneWidget);

      // Ambil widget TextField untuk mengecek properti obscureText
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      // Pastikan ikon default adalah visibility_off (mata dicoret)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Interaksi Toggle: Menekan ikon mata harus mengubah state obscureText secara internal', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsPasswordField(
            label: 'Password',
            controller: controller,
          ),
        ),
      );

      // --- STATE AWAL (Tertutup) ---
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // --- AKSI: Tap ikon mata ---
      // Kita cari IconButton yang membungkus ikon tersebut
      await tester.tap(find.byType(IconButton));
      await tester.pump(); // Render ulang setelah setState dipanggil di dalam komponen

      // --- STATE KEDUA (Terbuka) ---
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget); // Ikon berubah menjadi mata terbuka

      // --- AKSI: Tap ikon mata lagi ---
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // --- STATE KETIGA (Kembali Tertutup) ---
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Input teks harus mengubah nilai controller dan memicu onChanged', (WidgetTester tester) async {
      final controller = TextEditingController();
      String capturedValue = '';

      await tester.pumpWidget(
        buildTestableWidget(
          DsPasswordField(
            label: 'Password',
            controller: controller,
            onChanged: (value) {
              capturedValue = value;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Rahasia123!');
      await tester.pump();

      expect(controller.text, 'Rahasia123!');
      expect(capturedValue, 'Rahasia123!');
    });

    testWidgets('Harus menampilkan errorText saat parameter diisi', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          DsPasswordField(
            label: 'Password',
            controller: controller,
            errorText: 'Password minimal 8 karakter',
          ),
        ),
      );

      // Verifikasi pesan error muncul
      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });
  });
}