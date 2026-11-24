import 'package:equatable/equatable.dart';

enum KompayMutationTone { success, danger, neutral }

/// Category icon when the row has no courier logo.
enum KompayMutationIcon { withdrawal, topup, subscription, order }

/// One row of `order-transaction-balance` (Kompay/Komship balance mutation).
class KompayMutation extends Equatable {
  const KompayMutation({
    required this.date,
    required this.title,
    required this.status,
    required this.tone,
    required this.amount,
    required this.balanceAfter,
    required this.icon,
    this.imageUrl,
    this.cnote,
    this.notes,
  });

  /// Transaction time in local time (API sends `yyyy-MM-dd HH:mm`).
  final DateTime? date;
  final String title;
  final String status;
  final KompayMutationTone tone;

  /// Signed amount; negative for money leaving the balance.
  final int amount;
  final int balanceAfter;
  final KompayMutationIcon icon;

  /// Courier logo for order rows.
  final String? imageUrl;
  final String? cnote;
  final String? notes;

  @override
  List<Object?> get props =>
      [date, title, status, tone, amount, balanceAfter, icon, imageUrl, cnote];
}

class KompayMutationResult extends Equatable {
  const KompayMutationResult({required this.items, required this.hasMore});

  final List<KompayMutation> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}

/// Filter values accepted by `order-transaction-balance` (comma separated),
/// as used by Komship's "Pilih Jenis Transaksi" sheet.
enum KompayMutationFilter {
  codReceived('1', 'Orderan COD Diterima'),
  nonCodShipping('2', 'Ongkir Non-COD'),
  nonCodCancelled('3', 'Ongkir Non-COD Dibatalkan'),
  withdrawal('4', 'Tarik Saldo'),
  topup('5', 'Top-up Saldo'),
  codReturn('6', 'Retur COD'),
  claimReturn('7', 'Claim Retur Diterima'),
  lostPackage('8', 'Ganti Rugi Paket Hilang'),
  damagedPackage('9', 'Ganti Rugi Paket Rusak'),
  talentShop('10', 'Belanja Talent Komtim'),
  komtimRefund('11', 'Pengembalian Dana Komtim');

  const KompayMutationFilter(this.value, this.label);

  final String value;
  final String label;
}
