import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Sesuaikan import path dengan struktur foldermu
import 'package:komtim_partner/common/global/design_system/components/ds_bottom_sheet.dart';

void main() {
  group('DsBottomSheet Component Tests', () {
    
    // Helper minimal untuk merender widget tanpa full app bootstrap
    Widget buildTestableWidget(Widget widget) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: widget),
        ),
      );
    }

    testWidgets('Visual State: Harus merender title, description, dan tombol primary (Default)', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DsBottomSheet(
            title: 'Hapus Akun',
            description: 'Apakah Anda yakin ingin menghapus akun ini?',
            primaryButtonText: 'Ya, Hapus',
            onPrimaryPressed: () {},
          ),
        ),
      );

      // Verifikasi Teks Utama dirender dengan benar
      expect(find.text('Hapus Akun'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus akun ini?'), findsOneWidget);
      
      // Verifikasi tombol primary muncul dengan teks yang benar
      expect(find.text('Ya, Hapus'), findsOneWidget);

      // Verifikasi ikon silang (close) muncul karena isDismissible default-nya true
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verifikasi tombol sekunder TIDAK muncul karena parameternya null (Boundary test)
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('Visual State: Harus merender tombol sekunder saat parameter diberikan', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DsBottomSheet(
            title: 'Peringatan',
            description: 'Simpan perubahan?',
            primaryButtonText: 'Simpan',
            secondaryButtonText: 'Batal', // Parameter opsional diisi
            onPrimaryPressed: () {},
            onSecondaryPressed: () {},
          ),
        ),
      );

      // Verifikasi tombol sekunder (TextButton) dirender
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('Visual State: TIDAK merender ikon silang jika isDismissible = false', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DsBottomSheet(
            title: 'Loading',
            description: 'Mohon tunggu sebentar...',
            primaryButtonText: 'Tutup',
            isDismissible: false, // Konfigurasi flag dimatikan
            onPrimaryPressed: () {},
          ),
        ),
      );

      // Verifikasi ikon silang benar-benar tidak ditemukan di UI tree
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('Interaksi: Callback onPrimary, onSecondary, dan onClose harus terpicu saat di-tap', (WidgetTester tester) async {
      bool isPrimaryTapped = false;
      bool isSecondaryTapped = false;
      bool isCloseTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DsBottomSheet(
            title: 'Interaksi',
            description: 'Uji coba klik',
            primaryButtonText: 'Utama',
            secondaryButtonText: 'Sekunder',
            onPrimaryPressed: () => isPrimaryTapped = true,
            onSecondaryPressed: () => isSecondaryTapped = true,
            onClosePressed: () => isCloseTapped = true, // Callback custom
          ),
        ),
      );

      // 1. Uji klik primary button
      await tester.tap(find.text('Utama'));
      expect(isPrimaryTapped, isTrue);

      // 2. Uji klik secondary button
      await tester.tap(find.text('Sekunder'));
      expect(isSecondaryTapped, isTrue);

      // 3. Uji klik ikon close
      await tester.tap(find.byIcon(Icons.close));
      expect(isCloseTapped, isTrue);
    });
  });
}