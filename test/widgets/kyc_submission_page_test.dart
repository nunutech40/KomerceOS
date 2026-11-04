import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_submission_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_photo_capture_section.dart';

void main() {
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
}
