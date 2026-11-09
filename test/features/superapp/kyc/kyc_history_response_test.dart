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
    expect(history?.hasCompleteImages, false);
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
    expect(history?.hasCompleteImages, false);
  });

  test('draft dengan tiga gambar server langsung bisa ke formulir akhir', () {
    final history = KycHistoryResponse.parse({
      'meta': {'status': 'success'},
      'data': {
        'liveness_picture': {'url': 'https://example.com/liveness.jpg'},
        'ktp_picture': {'url': 'https://example.com/ktp.jpg'},
        'ktp_face_picture': {'url': 'https://example.com/selfie.jpg'},
        'info_data_partner': {'nik': '1234567890123456'},
      },
    });
    expect(history?.hasCompleteImages, true);
    expect(history?.partnerData['nik'], '1234567890123456');
  });

  test('draft liveness tanpa URL tetap bisa submit bila KTP dan selfie ada',
      () {
    final history = KycHistoryResponse.parse({
      'meta': {'status': 'success'},
      'data': {
        'liveness_picture': {'status': 'draft', 'url': ''},
        'ktp_picture': {
          'status': 'draft',
          'url': 'https://example.com/ktp.jpg'
        },
        'ktp_face_picture': {
          'status': 'draft',
          'url': 'https://example.com/selfie.jpg'
        },
        'info_data_partner': null,
      },
    });
    expect(history?.hasCompleteImages, true);
  });

  test('riwayat requested dikenali sesudah pengajuan berhasil', () {
    final history = KycHistoryResponse.parse({
      'meta': {'status': 'success'},
      'data': {
        'status': 'requested',
        'liveness_picture': {'status': 'requested', 'url': ''},
        'ktp_picture': {
          'status': 'requested',
          'url': 'https://example.com/ktp.jpg'
        },
        'ktp_face_picture': {
          'status': 'requested',
          'url': 'https://example.com/selfie.jpg'
        },
      },
    });
    expect(history?.isRequested, true);
  });
}
