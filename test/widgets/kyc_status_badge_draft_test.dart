import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_status_badge.dart';

void main() {
  testWidgets('badge draft menampilkan teks dan icon dokumen', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: KycStatusBadge.draft())),
    ));

    expect(find.text('Draft'), findsOneWidget);
    expect(find.byIcon(Icons.description_outlined), findsOneWidget);
  });
}
