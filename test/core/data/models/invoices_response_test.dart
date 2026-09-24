import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/models/invoices_response.dart';

void main() {
  test('maps is_paid false to unpaid transaction status', () {
    const response = InvoicesResponseData(
      invoiceId: 2731,
      invoiceCode: 'KM/INV/206768401-101503',
      isPaid: false,
      amountTotal: 115540,
      expiredAt: '',
      createdAt: '2026-09-23 09:18:00',
      updatedAt: '2026-09-23 09:18:12',
    );

    final invoice = response.toEntity();

    expect(invoice.isPaid, isFalse);
    expect(invoice.transactionStatus, 'unpaid');
  });

  test('maps is_paid true to paid transaction status', () {
    const response = InvoicesResponseData(
      invoiceId: 2732,
      invoiceCode: 'KM/INV/206768401-101504',
      isPaid: true,
      amountTotal: 65540,
      expiredAt: '',
      createdAt: '2026-09-23 09:18:00',
      updatedAt: '2026-09-23 09:18:12',
    );

    expect(response.toEntity().transactionStatus, 'paid');
  });
}
