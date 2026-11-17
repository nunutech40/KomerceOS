import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/withdrawal_no_bank_sheet.dart';

void main() {
  testWidgets('popup rekening kosong bisa kembali atau tambah rekening',
      (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool? choice;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
            builder: (context) => TextButton(
                  onPressed: () async {
                    choice = await WithdrawalNoBankSheet.show(context);
                  },
                  child: const Text('Buka'),
                )),
      ),
    ));

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu Belum Menambahkan Rekening'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(choice, isFalse);

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Sekarang'));
    await tester.pumpAndSettle();
    expect(choice, isTrue);
  });
}
