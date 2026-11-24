import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';

/// Parses `GET api/v1/partner/order-transaction-balance`.
///
/// Labels follow Komship Android `BalanceHistoryPagedListAdapter` so both apps
/// describe the same mutation the same way.
abstract final class KompayMutationResponse {
  static KompayMutationResult parsePage(dynamic body) {
    if (body is! Map) {
      throw const FormatException('Respons mutasi tidak valid');
    }
    final status = body['status'];
    if (status is String && status != 'success') {
      throw StateError('${body['message'] ?? 'Mutasi gagal dimuat'}');
    }
    final data = body['data'];
    // The API returns `data: {}` when a search has no match.
    if (data is! Map) return const KompayMutationResult(items: [], hasMore: false);
    final rows = data['data'];
    final items = rows is List
        ? rows.whereType<Map>().map(parseRow).toList()
        : <KompayMutation>[];
    final current = _int(data['current_page']);
    final last = _int(data['last_page']);
    return KompayMutationResult(
      items: items,
      hasMore: data['next_page_url'] != null || (current > 0 && current < last),
    );
  }

  static KompayMutation parseRow(Map row) {
    final type = _text(row['transaction_type']);
    final payment = _text(row['payment_method']);
    final crossBorder = row['description'] == 'is_crossborder';
    final courier = _text(row['shipment_image_path']);

    String orderTitle() => switch (payment) {
          'COD' => 'Orderan COD',
          'BANK TRANSFER' => 'Orderan Non-COD',
          '' || '-' => 'Orderan',
          _ => 'Orderan $payment',
        };

    KompayMutation build(String title, String status, KompayMutationTone tone,
            KompayMutationIcon icon,
            {bool courierLogo = false}) =>
        KompayMutation(
          date: _date(row['date_transaction']),
          title: title,
          status: status,
          tone: tone,
          amount: _signedAmount(row['amount_kmpoin'] ?? row['amount']),
          balanceAfter: _int(row['saldo']),
          icon: icon,
          imageUrl: courierLogo && courier.isNotEmpty ? courier : null,
          cnote: _optional(row['cnote']),
          notes: _optional(row['notes']),
        );

    const ok = KompayMutationTone.success;
    const bad = KompayMutationTone.danger;
    const info = KompayMutationTone.neutral;
    const order = KompayMutationIcon.order;

    switch (type) {
      case 'withdrawal':
        return build('Penarikan Saldo Kompay', 'Diterima', ok,
            KompayMutationIcon.withdrawal);
      case 'topup':
        if (row['claim_retur'] != null) {
          return build('Orderan COD', 'Claim Retur', info, order,
              courierLogo: true);
        }
        return build('Top Up Saldo', 'Sukses', ok, KompayMutationIcon.topup);
      case 'topup_komcard':
        return build('Top Up Saldo', 'Sukses', ok, KompayMutationIcon.topup);
      case 'refund_komcard':
        return build(
            'Refund Saldo', 'Sukses', ok, KompayMutationIcon.withdrawal);
      case 'payment_feature':
        return build('Berlangganan Fitur', 'Sukses', ok,
            KompayMutationIcon.subscription);
      case 'paid_verification':
        return build('Pembayaran Verifikasi KTP', 'Sukses', ok,
            KompayMutationIcon.subscription);
      case 'orderku_done':
        final orderStatus = _text(row['order_status']);
        final (label, tone) = switch (orderStatus) {
          'Hilang' => ('Ganti Rugi Paket Hilang', info),
          'Rusak' => ('Ganti Rugi Paket Rusak', info),
          'Diterima' => ('Diterima', ok),
          '' => ('-', info),
          _ => (orderStatus, info),
        };
        return build(orderTitle(), label, tone, order, courierLogo: true);
      case 'orderku_ongkir':
        return build('Orderan Non-COD', crossBorder ? 'Ongkir + VAT' : 'Ongkir',
            info, order,
            courierLogo: true);
      case 'orderku_cancel':
        return build('Orderan Non-COD',
            crossBorder ? 'Cancel, Ongkir + VAT' : 'Cancel', bad, order,
            courierLogo: true);
      case 'orderku_retur':
        final label =
            payment == 'COD' && crossBorder ? 'Retur (Ongkir + VAT)' : 'Retur';
        return build(orderTitle(), label, bad, order, courierLogo: true);
      case 'insurance_fee':
        return build(orderTitle(), 'Asuransi', bad, order, courierLogo: true);
      case 'insurance_cancel':
        return build(orderTitle(), 'Cancel Asuransi', ok, order,
            courierLogo: true);
      case 'claim':
        final label = switch (_text(row['claim_type'])) {
          'rts_rusak' || 'rusak' => 'Ganti Rugi Paket Rusak',
          'rts_tidak_diterima' ||
          'tidak_diterima' ||
          'hilang' =>
            'Ganti Rugi Paket Hilang',
          'paksa_diterima' => 'Diterima',
          _ => 'Retur',
        };
        return build(orderTitle(), label, info, order, courierLogo: true);
      default:
        // balance_reduction, transfer, and unknown types (Komship default).
        return build('Pengurangan Saldo', 'Sukses', ok,
            KompayMutationIcon.withdrawal);
    }
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static String? _optional(dynamic value) {
    final text = _text(value);
    return text.isEmpty || text == '-' ? null : text;
  }

  static int _int(dynamic value) => num.tryParse(_text(value))?.toInt() ?? 0;

  /// `amount_kmpoin` is a string such as `+25000` or `-25000`.
  static int _signedAmount(dynamic value) =>
      num.tryParse(_text(value).replaceAll('+', ''))?.toInt() ?? 0;

  static DateTime? _date(dynamic value) {
    final text = _text(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }
}
