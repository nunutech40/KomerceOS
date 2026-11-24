import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/notification/widget/notification_display.dart';

void main() {
  test('status di akhir judul dipisah dan diberi warna', () {
    final withdrawal =
        NotificationTitleParts.parse('Penarikan Saldo Kompay - Diterima');
    expect(withdrawal.title, 'Penarikan Saldo Kompay');
    expect(withdrawal.status, 'Diterima');
    expect(withdrawal.statusColor, NotificationTitleParts.success);

    final ktp = NotificationTitleParts.parse('Verifikasi KTP - Ditolak');
    expect(ktp.title, 'Verifikasi KTP');
    expect(ktp.status, 'Ditolak');
    expect(ktp.statusColor, NotificationTitleParts.danger);

    final claim = NotificationTitleParts.parse(
        'Claim Paket Force Return to Sender - Disetujui');
    expect(claim.title, 'Claim Paket Force Return to Sender');
    expect(claim.status, 'Disetujui');
  });

  test('judul tanpa status yang dikenal tidak diubah', () {
    final plain = NotificationTitleParts.parse('Promo Ongkir - Spesial');
    expect(plain.title, 'Promo Ongkir - Spesial');
    expect(plain.status, isNull);
    expect(NotificationTitleParts.parse(null).title, '');
  });
}
