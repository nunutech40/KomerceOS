import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/domain/entities/bank_accounts_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/view/bank_account_page.dart';
import 'package:komtim_partner/features/superapp/features/setting/widget/bank_account_pin_sheet.dart';

void main() {
  testWidgets('daftar rekening menampilkan semua data yang diterima',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: BankAccountPage(
      loadAccounts: () async => [
        BankAccountsDataModel(
            bankName: 'BCA',
            bankOwnerName: 'Jhon Doe',
            bankOwnerNumber: '0028911987'),
        BankAccountsDataModel(
            bankName: 'Permata',
            bankOwnerName: 'Jhon Doe',
            bankOwnerNumber: '11883943493'),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('0028911987'), findsOneWidget);
    expect(find.textContaining('11883943493'), findsOneWidget);
    expect(find.text('Tambah Rekening'), findsOneWidget);
  });

  testWidgets('lookup nama yang tidak ditemukan menahan tombol konfirmasi',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: BankAccountPage(
      loadAccounts: () async => [],
      lookupOwner: (_, __) async => null,
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Rekening'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih Bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permata').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '986672348294');
    await tester.tap(find.text('Cek Nama Pemilik Bank'));
    await tester.pumpAndSettle();

    expect(find.text('× Tidak Ditemukan'), findsOneWidget);
    expect(
        tester
            .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Konfirmasi'))
            .onPressed,
        isNull);
  });

  testWidgets('nomor rekening hanya menerima angka dan maksimal 20 digit',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BankAccountPage(loadAccounts: () async => []),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Rekening'));
    await tester.pumpAndSettle();

    final field = find.byType(TextFormField);
    await tester.enterText(field, '1234567890123456789012345');
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller?.text,
        '12345678901234567890');
    await tester.enterText(field, '12ab34');
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller?.text, '1234');
  });

  testWidgets('error cek rekening tetap di form dan menahan konfirmasi',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BankAccountPage(
        loadAccounts: () async => [],
        lookupOwner: (_, __) async => throw StateError('Rekening sudah digunakan'),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Rekening'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih Bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permata').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '986672348294');
    await tester.tap(find.text('Cek Nama Pemilik Bank'));
    await tester.pumpAndSettle();

    expect(find.text('Rekening sudah digunakan'), findsOneWidget);
    expect(find.text('× Tidak Ditemukan'), findsNothing);
    expect(find.text('Tambah Rekening Bank'), findsOneWidget);
    expect(find.text('Pilih Metode Verifikasi'), findsNothing);
    expect(
      tester
          .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Konfirmasi'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('gagal memuat daftar dapat dicoba lagi', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(home: BankAccountPage(
      loadAccounts: () async {
        attempts++;
        if (attempts == 1) throw StateError('network');
        return [];
      },
    )));
    await tester.pumpAndSettle();
    expect(find.text('Oops, Terjadi Kesalahan'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Tidak Ada Rekening Bank'), findsOneWidget);
  });

  testWidgets('sheet PIN menunggu verifikasi sebelum memberi akses',
      (tester) async {
    final pending = Completer<BankPinVerificationResult>();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
      body: BankAccountPinSheet(
          onVerify: (_) => pending.future, onForgotPin: () {}, onLocked: () {}),
    )));
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('Konfirmasi'));
    await tester.pump();
    expect(find.text('Memverifikasi PIN...'), findsOneWidget);
    pending.complete(
        const BankPinVerificationResult(isValid: false, attemptsLeft: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tersisa 2 kali percobaan'), findsOneWidget);
  });

  testWidgets('maksimal enam rekening menonaktifkan tombol tambah',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BankAccountPage(
        loadAccounts: () async => List.generate(
          6,
          (index) => BankAccountsDataModel(
            bankName: 'BCA',
            bankOwnerName: 'Jhon Doe',
            bankOwnerNumber: '002891198$index',
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Rekening'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Tambah Rekening'),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('cek nama menampilkan loading lalu status ditemukan',
      (tester) async {
    final pending = Completer<String?>();
    await tester.pumpWidget(MaterialApp(
      home: BankAccountPage(
        loadAccounts: () async => [],
        lookupOwner: (_, __) => pending.future,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Rekening'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih Bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Permata').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '986672348294');
    await tester.tap(find.text('Cek Nama Pemilik Bank'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Konfirmasi'),
          )
          .onPressed,
      isNull,
    );

    pending.complete('Jhon Doe Assqaf');
    await tester.pumpAndSettle();
    expect(find.text('Jhon Doe Assqaf'), findsOneWidget);
    expect(find.text('✓ Ditemukan'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Konfirmasi'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('PIN terkunci menutup sheet dan memanggil lockout',
      (tester) async {
    var locked = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () => showModalBottomSheet<bool>(
              context: context,
              builder: (_) => BankAccountPinSheet(
                onVerify: (_) async => const BankPinVerificationResult(
                  isValid: false,
                  attemptsLeft: 0,
                  locked: true,
                ),
                onForgotPin: () {},
                onLocked: () => locked = true,
              ),
            ),
            child: const Text('Buka PIN'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Buka PIN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan 6 Digit PIN Kamu'), findsNothing);
    expect(locked, isTrue);
  });

  testWidgets('sheet PIN tetap dapat diakses ketika keyboard terbuka',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () => showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) => BankAccountPinSheet(
                onVerify: (_) async =>
                    const BankPinVerificationResult(isValid: false),
                onForgotPin: () {},
                onLocked: () {},
              ),
            ),
            child: const Text('Buka PIN'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Buka PIN'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    await tester.pumpAndSettle();

    expect(find.text('Masukkan 6 Digit PIN Kamu'), findsOneWidget);
    await tester.ensureVisible(find.text('Lupa PIN?'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Lupa PIN?')).dy, lessThan(500));
    await tester.ensureVisible(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Konfirmasi')).dy, lessThan(500));
    expect(tester.takeException(), isNull);
  });
}
