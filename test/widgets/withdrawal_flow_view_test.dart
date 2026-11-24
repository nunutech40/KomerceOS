import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_withdrawal.dart';
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
        find.text('Masih ada penarikan yang diproses. Silakan tunggu hingga selesai untuk mengajukan penarikan baru.'), findsOneWidget);
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
      builder: (_) => const WithdrawalResultPage(withdrawal: _withdrawal),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Form Withdrawal'), findsNothing);
  });

  testWidgets('hasil berhasil memakai data response', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
        const MaterialApp(home: WithdrawalResultPage(withdrawal: _withdrawal)));
    await tester.pump();
    expect(find.text('Penarikan Saldo Berhasil'), findsOneWidget);
    expect(find.textContaining('Mandiri Ibnu Mufadlol', findRichText: true),
        findsOneWidget);
    // "Lihat Riwayat Penarikan" opens the live Mutasi page (needs DI and
    // API), covered by kompay_mutation_response_test.dart.
    expect(find.text('Lihat Riwayat Penarikan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hasil gagal menampilkan pesan BE dan kembali ke form',
      (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: Center(child: Text('Form Withdrawal'))),
    ));
    navigatorKey.currentState!.push(MaterialPageRoute<void>(
      builder: (_) =>
          const WithdrawalResultPage(failedMessage: 'Saldo tidak cukup'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Penarikan Gagal Diproses'), findsOneWidget);
    expect(find.textContaining('Saldo tidak cukup'), findsOneWidget);

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Form Withdrawal'), findsOneWidget);
  });
}

const _withdrawal = KompayWithdrawal(
  nominal: 500000,
  bankName: 'Mandiri',
  bankOwnerName: 'Ibnu Mufadlol',
);
