import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/flow/kyc_liveness_flow.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('setiap percobaan membuka panduan liveness dari awal',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'kyc_liveness_selfie_1': '/old/liveness_1.jpg',
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => KycLivenessFlow.start(context),
            child: const Text('Mulai KYC'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Mulai KYC'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Verifikasi Wajah Liveness'), findsOneWidget);
    expect(
        (await SharedPreferences.getInstance())
            .getString('kyc_liveness_selfie_1'),
        isNull);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai KYC'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Verifikasi Wajah Liveness'), findsOneWidget);
  });
}
