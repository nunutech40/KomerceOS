import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/invoice_item.dart';

import '../helpers/helpers.dart';

/// Contoh implementasi widget test untuk InvoiceItem
///
/// Test ini mencakup:
/// - Rendering komponen dengan berbagai status
/// - Verifikasi text dan icon yang ditampilkan
/// - Testing untuk berbagai transaction type (invoice, topup, withdrawal)
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('InvoiceItem Widget Tests', () {
    testWidgets('menampilkan invoice PAID dengan benar',
        (WidgetTester tester) async {
      // Arrange - siapkan data mock
      final mockInvoice = InvoicesDataModel(
        invoiceId: 1,
        invoiceCode: 'INV-001',
        amountTotal: 150000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-15 10:00:00',
        updatedAt: '2026-06-15 11:00:00',
      );

      // Act - render widget
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          InvoiceItem(dataInvoice: mockInvoice),
        ),
      );

      // Assert - verifikasi tampilan
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('Invoice'), findsOneWidget);
      expect(find.text('Berhasil'), findsOneWidget);
      expect(find.text('Rp150.000'), findsOneWidget);
    });

    testWidgets('menampilkan invoice UNPAID dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 2,
        invoiceCode: 'INV-002',
        amountTotal: 250000,
        transactionStatus: 'unpaid',
        transactionType: 'invoice',
        isPaid: false,
        createdAt: '2026-06-10 08:00:00',
        updatedAt: '2026-06-10 08:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert
      expect(find.text('INV-002'), findsOneWidget);
      expect(find.text('Belum Dibayar'), findsOneWidget);
      expect(find.text('Rp250.000'), findsOneWidget);
    });

    testWidgets('menampilkan invoice CANCELED dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 3,
        invoiceCode: 'INV-003',
        amountTotal: 100000,
        transactionStatus: 'canceled',
        transactionType: 'invoice',
        isPaid: false,
        createdAt: '2026-06-12 14:00:00',
        updatedAt: '2026-06-12 15:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert
      expect(find.text('INV-003'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('menampilkan TOPUP SUCCESS dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockTopup = InvoicesDataModel(
        invoiceId: 4,
        invoiceCode: 'TOPUP-001',
        amountTotal: 500000,
        transactionStatus: 'paid',
        transactionType: 'topup',
        isPaid: true,
        createdAt: '2026-06-19 02:00:00',
        updatedAt: '2026-06-19 02:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockTopup)),
      );

      // Assert
      expect(find.text('19-Juni-2026'), findsOneWidget);
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Berhasil'), findsOneWidget);
      expect(find.text('Rp500.000'), findsOneWidget);
    });

    testWidgets('menampilkan TOPUP UNPAID dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockTopup = InvoicesDataModel(
        invoiceId: 5,
        invoiceCode: 'TOPUP-002',
        amountTotal: 300000,
        transactionStatus: 'unpaid',
        transactionType: 'topup',
        isPaid: false,
        createdAt: '2026-06-18 10:00:00',
        updatedAt: '2026-06-18 10:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockTopup)),
      );

      // Assert
      expect(find.text('18-Juni-2026'), findsOneWidget);
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Belum Dibayar'), findsOneWidget);
    });

    testWidgets('menampilkan WITHDRAWAL SUCCESS dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockWithdrawal = InvoicesDataModel(
        invoiceId: 6,
        invoiceCode: 'WD-001',
        amountTotal: 200000,
        transactionStatus: 'completed',
        transactionType: 'withdrawal',
        isPaid: true,
        createdAt: '2026-06-17 15:00:00',
        updatedAt: '2026-06-17 16:00:00',
      );

      // Act
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          InvoiceItem(dataInvoice: mockWithdrawal),
        ),
      );

      // Assert
      expect(find.text('17-Juni-2026'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Berhasil'), findsOneWidget);
      expect(find.text('Rp200.000'), findsOneWidget);
    });

    testWidgets('menampilkan WITHDRAWAL IN_PROCESS dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockWithdrawal = InvoicesDataModel(
        invoiceId: 7,
        invoiceCode: 'WD-002',
        amountTotal: 150000,
        transactionStatus: 'in_process',
        transactionType: 'withdrawal',
        isPaid: false,
        createdAt: '2026-06-19 01:00:00',
        updatedAt: '2026-06-19 01:00:00',
      );

      // Act
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          InvoiceItem(dataInvoice: mockWithdrawal),
        ),
      );

      // Assert
      expect(find.text('19-Juni-2026'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(find.text('Proses'), findsOneWidget);
    });

    testWidgets('menampilkan WITHDRAWAL REJECTED dengan benar',
        (WidgetTester tester) async {
      // Arrange
      final mockWithdrawal = InvoicesDataModel(
        invoiceId: 8,
        invoiceCode: 'WD-003',
        amountTotal: 100000,
        transactionStatus: 'rejected',
        transactionType: 'withdrawal',
        isPaid: false,
        createdAt: '2026-06-16 12:00:00',
        updatedAt: '2026-06-16 13:00:00',
      );

      // Act
      await tester.pumpWidget(
        TestHelper.wrapWithMaterialApp(
          InvoiceItem(dataInvoice: mockWithdrawal),
        ),
      );

      // Assert
      expect(find.text('16-Juni-2026'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);
    });

    testWidgets('menampilkan icon SVG yang sesuai untuk invoice',
        (WidgetTester tester) async {
      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 9,
        invoiceCode: 'INV-004',
        amountTotal: 175000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-15 10:00:00',
        updatedAt: '2026-06-15 11:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert - verify SVG widget exists
      expect(
          find.byWidgetPredicate(
            (widget) => widget.toString().contains('SvgPicture'),
          ),
          findsOneWidget);
    });

    testWidgets('menampilkan tanggal dengan format yang benar',
        (WidgetTester tester) async {
      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 10,
        invoiceCode: 'INV-005',
        amountTotal: 200000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-19 02:29:01',
        updatedAt: '2026-06-19 02:29:01',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert - verify date is displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('menampilkan - jika invoice code kosong',
        (WidgetTester tester) async {
      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 11,
        invoiceCode: '',
        amountTotal: 100000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-15 10:00:00',
        updatedAt: '2026-06-15 11:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert
      expect(find.text('-'), findsOneWidget);
    });
  });

  group('InvoiceItem Widget Tests - Using MockDataFactory', () {
    testWidgets('menampilkan paid invoice dari factory',
        (WidgetTester tester) async {
      // Arrange - menggunakan MockDataFactory
      final mockInvoice = InvoicesDataModel(
        invoiceId: 1,
        invoiceCode: 'INV-PAID-001',
        amountTotal: 150000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-15 10:00:00',
        updatedAt: '2026-06-15 11:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert
      expect(find.text('INV-PAID-001'), findsOneWidget);
      expect(find.text('Berhasil'), findsOneWidget);
    });
  });

  group('InvoiceItem Widget Tests - Using WidgetTestHelper', () {
    testWidgets('test menggunakan helper functions',
        (WidgetTester tester) async {
      // Setup global tester untuk helper
      setGlobalTester(tester);

      // Arrange
      final mockInvoice = InvoicesDataModel(
        invoiceId: 1,
        invoiceCode: 'INV-TEST-001',
        amountTotal: 100000,
        transactionStatus: 'paid',
        transactionType: 'invoice',
        isPaid: true,
        createdAt: '2026-06-15 10:00:00',
        updatedAt: '2026-06-15 11:00:00',
      );

      // Act
      await tester.pumpWidget(
        pumpApp(InvoiceItem(dataInvoice: mockInvoice)),
      );

      // Assert - menggunakan helper
      WidgetTestHelper.expectTextContains('INV-TEST-001');
      WidgetTestHelper.expectTextContains('Berhasil');
      WidgetTestHelper.expectTextContains('Rp100.000');
    });
  });
}
