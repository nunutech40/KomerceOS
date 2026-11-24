import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/models/kompay_mutation_response.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/view/kompay_mutation_page.dart';

Map<String, dynamic> row(String type,
        {String amount = '-100000',
        String payment = '-',
        String? orderStatus,
        String? claimType,
        String? description,
        Object? claimRetur,
        String? courier}) =>
    {
      'date_transaction': '2026-11-13 13:21',
      'transaction_type': type,
      'amount_kmpoin': amount,
      'saldo': 2257987,
      'payment_method': payment,
      'order_status': orderStatus ?? '-',
      'claim_type': claimType,
      'description': description,
      'claim_retur': claimRetur,
      'shipment_image_path': courier,
      'cnote': '-',
    };

void main() {
  test('halaman mutasi dari order-transaction-balance (respons dev)', () {
    final page = KompayMutationResponse.parsePage({
      'status': 'success',
      'data': {
        'current_page': 1,
        'last_page': 1,
        'next_page_url': null,
        'data': [
          row('paid_verification', amount: '-25000'),
          row('topup', amount: '+25000'),
        ],
      },
    });
    expect(page.hasMore, false);
    expect(page.items.map((e) => e.title),
        ['Pembayaran Verifikasi KTP', 'Top Up Saldo']);
    expect(page.items.first.amount, -25000);
    expect(page.items.last.amount, 25000);
    expect(page.items.first.balanceAfter, 2257987);
    expect(page.items.first.date, DateTime(2026, 11, 13, 13, 21));
  });

  test('pencarian tanpa hasil mengembalikan data kosong', () {
    final page =
        KompayMutationResponse.parsePage({'status': 'success', 'data': {}});
    expect(page.items, isEmpty);
    expect(page.hasMore, false);
  });

  test('label mengikuti Komship', () {
    final withdrawal = KompayMutationResponse.parseRow(row('withdrawal'));
    expect(withdrawal.title, 'Penarikan Saldo Kompay');
    expect(withdrawal.status, 'Diterima');
    expect(withdrawal.tone, KompayMutationTone.success);

    final retur = KompayMutationResponse.parseRow(row('orderku_retur',
        payment: 'BANK TRANSFER', courier: 'https://x/jne.png'));
    expect(retur.title, 'Orderan Non-COD');
    expect(retur.status, 'Retur');
    expect(retur.tone, KompayMutationTone.danger);
    expect(retur.imageUrl, 'https://x/jne.png');

    final done = KompayMutationResponse.parseRow(
        row('orderku_done', payment: 'COD', orderStatus: 'Diterima'));
    expect(done.title, 'Orderan COD');
    expect(done.status, 'Diterima');

    final claim =
        KompayMutationResponse.parseRow(row('claim', claimType: 'hilang'));
    expect(claim.status, 'Ganti Rugi Paket Hilang');

    final claimRetur = KompayMutationResponse.parseRow(
        row('topup', amount: '+8500', claimRetur: 1));
    expect(claimRetur.title, 'Orderan COD');
    expect(claimRetur.status, 'Claim Retur');

    final unknown = KompayMutationResponse.parseRow(row('balance_reduction'));
    expect(unknown.title, 'Pengurangan Saldo');
  });

  test('label tanggal grup', () {
    final now = DateTime(2026, 11, 19, 10);
    expect(KompayMutationDates.groupLabel(DateTime(2026, 11, 19, 1), now),
        'Hari ini');
    expect(KompayMutationDates.groupLabel(DateTime(2026, 11, 18, 23), now),
        'Kemarin');
    expect(KompayMutationDates.groupLabel(DateTime(2025, 11, 18), now),
        '18 November 2025');
  });
}
