import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:komtim_partner/features/superapp/features/pin/bloc/account_pin_cubit.dart';
import 'package:komtim_partner/features/superapp/features/pin/view/pin_flow_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/bank_account_entry.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/bank_liability_sheet.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/bank_result_sheet.dart';

import '../test/widgets/fake_pin_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('popup sukses rekening pada perangkat', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () => BankResultSheet.show(
              context: context,
              title: 'Rekening Berhasil\nDitambahkan',
              description:
                  'Selamat! Nomor rekening berhasil\nditambahkan di akun kamu',
            ),
            child: const Text('Buka hasil rekening'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Buka hasil rekening'));
    await tester.pumpAndSettle();
    expect(find.text('Rekening Berhasil\nDitambahkan'), findsOneWidget);
    debugPrint('QA_SCREEN_BANK_SUCCESS');
    await Future<void>.delayed(const Duration(seconds: 12));
  });

  testWidgets('popup tanggungan pada perangkat', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) => TextButton(
          onPressed: () async {
            final note = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: const Color(0x73000000),
              builder: (_) => const BankLiabilitySheet(liabilities: [
                BankLiability(email: 'akun-uji@example.com', balance: -72525),
              ]),
            );
            if (note == null || !context.mounted) return;
            await BankResultSheet.show(
              context: context,
              title: 'Alasan Berhasil Diajukan',
              description: 'Alasan penambahan rekening berhasil\n'
                  'dikirim dan sedang ditinjau oleh tim.',
            );
          },
          child: const Text('Buka tanggungan'),
        )),
      ),
    ));
    await tester.tap(find.text('Buka tanggungan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alasan pengajuan uji');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Selesaikan Tanggungan'), findsNothing);
    expect(find.text('Kirim Alasan & Ajukan'), findsOneWidget);
    debugPrint('QA_SCREEN_BANK_LIABILITY');
    await Future<void>.delayed(const Duration(seconds: 12));
    await tester.tap(find.text('Kirim Alasan & Ajukan'));
    await tester.pumpAndSettle();
    expect(find.text('Alasan Berhasil Diajukan'), findsOneWidget);
    debugPrint('QA_SCREEN_REASON_SUCCESS');
    await Future<void>.delayed(const Duration(seconds: 12));
  });

  testWidgets('popup batas PIN saat login ulang pada perangkat', (tester) async {
    final controller = AccountPinCubit(FakePinRepository()..attemptLeft = 0);
    addTearDown(controller.close);
    await tester.pumpWidget(MaterialApp(
      home: PinFlowPage(
        flow: PinFlow.change,
        email: 'akun-uji@example.com',
        controller: controller,
        onLocked: () {},
      ),
    ));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(find.text('Terlalu Banyak Percobaan\nPIN'), findsOneWidget);
    debugPrint('QA_SCREEN_PIN_LOCK');
    await Future<void>.delayed(const Duration(seconds: 12));
  });

  testWidgets('PIN salah ketiga langsung memicu logout', (tester) async {
    var logoutCount = 0;
    final controller = AccountPinCubit(FakePinRepository());
    addTearDown(controller.close);
    await tester.pumpWidget(MaterialApp(
      home: PinFlowPage(
        flow: PinFlow.change,
        email: 'akun-uji@example.com',
        controller: controller,
        onLocked: () => logoutCount++,
      ),
    ));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 3; i++) {
      await tester.enterText(find.byType(TextField).first, '00000$i');
      await tester.pumpAndSettle();
    }
    expect(logoutCount, 1);
    expect(find.text('Terlalu Banyak Percobaan\nPIN'), findsNothing);
  });
}
