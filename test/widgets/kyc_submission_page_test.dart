import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_submission_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_photo_capture_section.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';

class _FakeKycRepository implements KycVerificationRepository {
  @override
  Future<KycHistory?> latestHistory() async => null;
  @override
  Future<void> upload(
      {String? ktpPath, String? selfieKtpPath, String? livenessPath}) async {}
  @override
  Future<void> checkNik({required String nik, required String email}) async {}
  @override
  Future<void> submit(Map<String, String> partnerData) async {}
}

void main() {
  setUpAll(() => locator
      .registerSingleton<KycVerificationRepository>(_FakeKycRepository()));
  tearDownAll(() => locator.unregister<KycVerificationRepository>());
  testWidgets('setelah liveness, langkah pertama adalah foto KTP',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: KycSubmissionPage(),
    ));
    await tester.pump();

    expect(find.text('Verifikasi Foto KTP'), findsOneWidget);
    expect(find.text('Ambil Foto KTP'), findsOneWidget);
    expect(find.text('Ambil Gambar'), findsOneWidget);
    expect(find.byType(KycPhotoCaptureSection), findsOneWidget);
    expect(find.text('Langkah 1 dari 4'), findsNothing);
    expect(find.text('Ambil Foto Selfie & KTP'), findsNothing);
    expect(find.text('Informasi Data Partner'), findsNothing);
  });

  testWidgets('draft lengkap dari latest-history langsung membuka form akhir',
      (tester) async {
    const history = KycHistory(
      livenessStatus: 'draft',
      ktpUrl: 'https://example.com/ktp.jpg',
      selfieKtpUrl: 'https://example.com/selfie.jpg',
      partnerData: {'nik': '1234567890123456'},
    );
    await tester.pumpWidget(const MaterialApp(
      home: KycSubmissionPage(history: history),
    ));

    expect(find.text('Informasi Data Partner'), findsWidgets);
    expect(find.text('Ajukan Verifikasi'), findsOneWidget);
    expect(find.text('Simpan sebagai Draft'), findsOneWidget);
    expect(find.byType(KycPhotoCaptureSection), findsNothing);
  });

  testWidgets('RT/RW hanya menerima angka dan garis miring', (tester) async {
    const history = KycHistory(
      livenessStatus: 'draft',
      ktpUrl: 'https://example.com/ktp.jpg',
      selfieKtpUrl: 'https://example.com/selfie.jpg',
    );
    await tester.pumpWidget(const MaterialApp(
      home: KycSubmissionPage(history: history),
    ));

    final rtRw = find.ancestor(
      of: find.text('Masukkan RT/RW'),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(rtRw);
    await tester.enterText(rtRw, 'bw01/0a2x');
    await tester.pump();

    final field = tester.widget<TextFormField>(rtRw);
    expect(field.controller!.text, '01/02');
  });

  testWidgets('RT/RW tanpa garis miring ditolak validasi', (tester) async {
    const history = KycHistory(
      livenessStatus: 'draft',
      ktpUrl: 'https://example.com/ktp.jpg',
      selfieKtpUrl: 'https://example.com/selfie.jpg',
    );
    await tester.pumpWidget(const MaterialApp(
      home: KycSubmissionPage(history: history),
    ));

    final rtRw = find.ancestor(
      of: find.text('Masukkan RT/RW'),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(rtRw);
    await tester.enterText(rtRw, '001002');
    await tester.pump();

    expect(find.text('Format RT/RW: 001/002'), findsOneWidget);
  });
}
