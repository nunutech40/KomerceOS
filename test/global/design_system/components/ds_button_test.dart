import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import path dengan struktur foldermu
import 'package:komtim_partner/common/global/design_system/components/ds_button.dart'; 

void main() {
  group('DsButton Component Tests', () {
    
    // Helper untuk membungkus widget dengan MaterialApp
    Widget buildTestableWidget(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: widget),
        ),
      );
    }

    testWidgets('Harus menampilkan teks yang benar pada state default (enabled)', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DsButton(
            text: 'Simpan Data',
            onPressed: () {},
          ),
        ),
      );

      // Verifikasi teks muncul
      expect(find.text('Simpan Data'), findsOneWidget);
      // Verifikasi tidak ada indikator loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onPressed harus dieksekusi saat tombol di-tap pada state enabled', (WidgetTester tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DsButton(
            text: 'Klik Saya',
            state: DsButtonState.enabled,
            onPressed: () {
              isTapped = true;
            },
          ),
        ),
      );

      // Lakukan aksi tap
      await tester.tap(find.byType(DsButton));
      await tester.pumpAndSettle();

      // Verifikasi callback terpanggil
      expect(isTapped, isTrue);
    });

    testWidgets('onPressed TIDAK boleh dieksekusi saat tombol di-tap pada state disabled', (WidgetTester tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DsButton(
            text: 'Tidak Bisa Diklik',
            state: DsButtonState.disabled,
            onPressed: () {
              isTapped = true;
            },
          ),
        ),
      );

      // Lakukan aksi tap
      await tester.tap(find.byType(DsButton));
      await tester.pump();

      // Verifikasi callback tidak terpanggil (false)
      expect(isTapped, isFalse);
    });

    testWidgets('Harus menampilkan loadingText & CircularProgressIndicator, serta menahan tap saat state loading', (WidgetTester tester) async {
      bool isTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DsButton(
            text: 'Masuk',
            loadingText: 'Memuat...',
            state: DsButtonState.loading,
            onPressed: () {
              isTapped = true;
            },
          ),
        ),
      );

      // Verifikasi teks berubah menjadi loadingText
      expect(find.text('Memuat...'), findsOneWidget);
      // Verifikasi indikator loading muncul
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Lakukan aksi tap
      await tester.tap(find.byType(DsButton));
      await tester.pump(); // Pakai pump(), bukan pumpAndSettle() karena ada animasi loading

      // Verifikasi callback tidak terpanggil saat sedang loading
      expect(isTapped, isFalse);
    });
  });
}