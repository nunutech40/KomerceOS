import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/withdrawal_balance_sheet.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/withdrawal_page.dart';

void main() {
  testWidgets('popup antrean menampilkan pesan menunggu withdrawal',
      (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WithdrawalBalanceSheet(notice: WithdrawalBalanceNotice.pending),
      ),
    ));
    await tester.pump();

    expect(
        find.text('Menunggu withdrawal sebelumnya selesai.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kembali dari hasil penarikan menuju Home', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: Center(child: Text('Home'))),
    ));
    navigatorKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Form Withdrawal'))),
    ));
    navigatorKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => WithdrawalResultPreviewPage(
        amount: 500000,
        balance: 999999999,
        bank: BankAccountsDataModel(
          bankName: 'Mandiri',
          bankOwnerName: 'Ibnu Mufadlol',
          bankOwnerNumber: '12345678',
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Form Withdrawal'), findsNothing);
  });

  testWidgets('pratinjau hasil membuka riwayat dan state gagal',
      (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: WithdrawalResultPreviewPage(
        amount: 500000,
        balance: 999999999,
        bank: BankAccountsDataModel(
          bankName: 'Mandiri',
          bankOwnerName: 'Ibnu Mufadlol',
          bankOwnerNumber: '12345678',
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Penarikan Saldo Berhasil'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lihat Riwayat Penarikan'));
    await tester.pumpAndSettle();
    expect(find.text('Mutasi Transaksi'), findsOneWidget);
    expect(find.text('PRATINJAU · BELUM ADA TRANSAKSI'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    await tester.tap(find.text('State gagal'));
    await tester.pumpAndSettle();
    expect(find.text('Penarikan Gagal Diproses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
