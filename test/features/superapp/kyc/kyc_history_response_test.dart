import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/models/kyc_history_response.dart';

void main() {
  test('riwayat kosong memulai liveness', () {
    final history = KycHistoryResponse.parse({
      'meta': {'status': 'success'},
      'data': {
        'liveness_picture': {'status': '', 'url': ''},
        'ktp_picture': {'status': '', 'url': ''},
        'ktp_face_picture': {'status': '', 'url': ''},
        'info_data_partner': null,
      },
    });
    expect(history?.hasUploadedLiveness, false);
    expect(history?.hasKtp, false);
  });

  test('riwayat liveness yang punya URL melanjutkan foto KTP', () {
    final history = KycHistoryResponse.parse({
      'meta': {'status': 'success'},
      'data': {
        'liveness_picture': {'status': '', 'url': 'https://example.com/a.jpg'},
        'ktp_picture': {'status': '', 'url': ''},
        'ktp_face_picture': {'status': '', 'url': ''},
        'info_data_partner': {'name': 'Sample'},
      },
    });
    expect(history?.hasUploadedLiveness, true);
    expect(history?.hasKtp, false);
    expect(history?.partnerData['name'], 'Sample');
  });
}
