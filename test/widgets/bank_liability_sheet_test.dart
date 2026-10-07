import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/bank_account_entry.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/bank_liability_sheet.dart';

void main() {
  testWidgets('Selesaikan Tanggungan hanya menutup modal', (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? result = 'belum ditutup';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () async {
              result = await showModalBottomSheet<String>(
                context: context,
                builder: (_) => const BankLiabilitySheet(liabilities: [
                  BankLiability(email: 's***@mail.com', balance: -17000),
                ]),
              );
            },
            child: const Text('Buka form rekening'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('Buka form rekening'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selesaikan Tanggungan'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.byType(BankLiabilitySheet), findsNothing);
    expect(find.text('Buka form rekening'), findsOneWidget);
    expect(find.text('Mengerti'), findsNothing);
  });

  testWidgets('saldo minus satu akun meminta alasan minimal sepuluh karakter',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BankLiabilitySheet(liabilities: [
          BankLiability(email: 's***@mail.com', balance: -17000),
        ]),
      ),
    ));
    expect(find.text('s***@mail.com'), findsOneWidget);
    expect(find.text('-Rp17.000'), findsOneWidget);
    expect(
        tester
            .widget<TextButton>(
                find.widgetWithText(TextButton, 'Kirim Alasan & Ajukan'))
            .onPressed,
        isNull);

    await tester.enterText(find.byType(TextField), '          ');
    await tester.pump();
    expect(
        tester
            .widget<TextButton>(
                find.widgetWithText(TextButton, 'Kirim Alasan & Ajukan'))
            .onPressed,
        isNull);

    await tester.enterText(find.byType(TextField), 'Alasan valid');
    await tester.pump();
    expect(
        tester
            .widget<TextButton>(
                find.widgetWithText(TextButton, 'Kirim Alasan & Ajukan'))
            .onPressed,
        isNotNull);
  });

  testWidgets('tanggungan multi akun ditampilkan dalam daftar scroll',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BankLiabilitySheet(liabilities: [
          BankLiability(email: 'a***@mail.com', balance: -10000),
          BankLiability(email: 'b***@mail.com', balance: -25000),
          BankLiability(email: 'c***@mail.com', balance: -35000),
        ]),
      ),
    ));
    expect(find.text('a***@mail.com'), findsOneWidget);
    expect(find.text('b***@mail.com'), findsOneWidget);
    expect(find.text('c***@mail.com'), findsOneWidget);
  });
}
