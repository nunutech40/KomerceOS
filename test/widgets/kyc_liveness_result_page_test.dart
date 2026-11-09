import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_liveness_result_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_ktp_guide_bottom_sheet.dart';

void main() {
  testWidgets(
      'hasil liveness tampil dulu, lalu Selanjutnya membuka panduan KTP',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: KycLivenessResultPage(livenessPath: '/tmp/kyc-liveness-test.jpg'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(KycLivenessResultPage), findsOneWidget);
    expect(find.byType(KycKtpGuideBottomSheet), findsNothing);
    expect(find.text('Verifikasi Wajah Berhasil'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    await tester.tap(find.text('Selanjutnya'));
    await tester.pumpAndSettle();
    expect(find.byType(KycKtpGuideBottomSheet), findsOneWidget);
    expect(find.text('Verifikasi Foto KTP'), findsOneWidget);
    final buttonCenter = tester.getCenter(find.text('Mulai Foto'));
    expect(buttonCenter.dy, lessThan(800));
    expect(buttonCenter.dy, greaterThan(0));
  });
}
