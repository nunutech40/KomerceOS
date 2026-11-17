import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_radio_button.dart';
import 'package:komtim_partner/core/domain/usecases/create_invoice_use_case.dart';
import 'package:komtim_partner/core/domain/usecases/create_qrcode_use_case.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/create_invoice_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/bloc/create_qrcode_bloc.dart';
import 'package:komtim_partner/features/superapp/features/topup/view/topup_page.dart';

class _MockCreateInvoiceUseCase extends Mock implements CreateInvoiceUseCase {}

class _MockCreateQrcodeUseCase extends Mock implements CreateQrcodeUseCase {}

void main() {
  testWidgets('Top Up KYC menampilkan kedua metode dan konfirmasi QRIS',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final invoiceBloc =
        CreateInvoiceBloc(createInvoiceUseCase: _MockCreateInvoiceUseCase());
    final qrBloc = CreateQrcodeBloc(useCase: _MockCreateQrcodeUseCase());
    addTearDown(invoiceBloc.close);
    addTearDown(qrBloc.close);

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<CreateInvoiceBloc>.value(value: invoiceBloc),
        BlocProvider<CreateQrcodeBloc>.value(value: qrBloc),
      ],
      child: const MaterialApp(home: TopupView(isFromKyc: true)),
    ));

    expect(find.textContaining('Verifikasi Akun bernilai', findRichText: true),
        findsOneWidget);
    final bank = find.widgetWithText(DsRadioButton, 'Transfer Bank');
    final qris = find.widgetWithText(DsRadioButton, 'QRIS');
    expect(bank, findsOneWidget);
    expect(qris, findsOneWidget);

    await tester.tap(find.text('Rp 50.000'));
    await tester.ensureVisible(qris);
    await tester.pumpAndSettle();
    await tester.tap(qris);
    await tester.pumpAndSettle();
    expect(tester.widget<DsRadioButton>(qris).selected, isTrue);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    expect(find.text('Nominal Top Up'), findsOneWidget);
    expect(find.text('Total Tagihan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Transfer Bank menampilkan biaya layanan dan total tagihan',
      (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final invoiceBloc =
        CreateInvoiceBloc(createInvoiceUseCase: _MockCreateInvoiceUseCase());
    final qrBloc = CreateQrcodeBloc(useCase: _MockCreateQrcodeUseCase());
    addTearDown(invoiceBloc.close);
    addTearDown(qrBloc.close);

    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<CreateInvoiceBloc>.value(value: invoiceBloc),
        BlocProvider<CreateQrcodeBloc>.value(value: qrBloc),
      ],
      child: const MaterialApp(home: TopupView(isFromKyc: true)),
    ));

    await tester.tap(find.text('Rp 50.000'));
    final bank = find.widgetWithText(DsRadioButton, 'Transfer Bank');
    await tester.ensureVisible(bank);
    await tester.pumpAndSettle();
    await tester.tap(bank);
    await tester.pumpAndSettle();
    expect(tester.widget<DsRadioButton>(bank).selected, isTrue);

    await tester.tap(find.text('Top Up'));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    expect(find.text('Rp 1.000'), findsOneWidget);
    expect(find.text('Rp 51.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
