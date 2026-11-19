import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/models/kyc_history_response.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';

/// Builds a `latest-history` body shaped like the dev response for
/// testsuper3 (18 Nov 2026): per-photo status + notes, overall status.
KycHistory parseRejected({
  required String liveness,
  required String ktp,
  required String selfie,
  String? ktpNotes,
  String status = 'rejected',
}) {
  return KycHistoryResponse.parse({
    'meta': {'status': 'success'},
    'data': {
      'status': status,
      'liveness_picture': {'notes': 'wajah buram', 'url': '', 'status': liveness},
      'ktp_picture': {
        'notes': ktpNotes,
        'url': 'https://example.com/ktp.jpg',
        'status': ktp,
      },
      'ktp_face_picture': {
        'notes': null,
        'url': 'https://example.com/selfie.jpg',
        'status': selfie,
      },
      'info_data_partner': {'nik': '3307092111010005', 'name': 'Coba KYC'},
    },
  })!;
}

void main() {
  test('catatan penolakan per berkas terbaca dari latest-history', () {
    final history = parseRejected(
        liveness: 'rejected',
        ktp: 'rejected',
        selfie: 'approved',
        ktpNotes: 'NIK tidak terbaca');
    expect(history.isRejected, true);
    expect(history.ktpNotes, 'NIK tidak terbaca');
    expect(history.livenessNotes, 'wajah buram');
    expect(history.selfieKtpNotes, isNull);
    expect(history.notesFor(KycRejectedItem.ktp), 'NIK tidak terbaca');
    expect(history.notesFor(KycRejectedItem.partnerData), isNull);
  });

  test('liveness + KTP ditolak: urutan popup liveness lalu KTP', () {
    final history =
        parseRejected(liveness: 'rejected', ktp: 'rejected', selfie: 'approved');
    expect(history.rejectedItems,
        [KycRejectedItem.liveness, KycRejectedItem.ktp]);
    // KTP rejected → liveness + KTP + selfie redone.
    expect(history.mustRetakeLiveness, true);
    expect(history.mustRetakeKtp, true);
    expect(history.mustRetakeSelfieKtp, true);
  });

  test('hanya KTP ditolak: ulang liveness, KTP, dan selfie', () {
    final history =
        parseRejected(liveness: 'approved', ktp: 'rejected', selfie: 'approved');
    expect(history.rejectedItems, [KycRejectedItem.ktp]);
    expect(history.mustRetakeLiveness, true);
    expect(history.mustRetakeKtp, true);
    expect(history.mustRetakeSelfieKtp, true);
  });

  test('hanya selfie ditolak: ulang selfie + KTP, liveness dipertahankan', () {
    final history =
        parseRejected(liveness: 'approved', ktp: 'approved', selfie: 'rejected');
    expect(history.rejectedItems, [KycRejectedItem.selfieKtp]);
    expect(history.mustRetakeLiveness, false);
    expect(history.mustRetakeKtp, true);
    expect(history.mustRetakeSelfieKtp, true);
  });

  test('hanya liveness ditolak: ulang liveness + KTP, selfie dilewati', () {
    final history =
        parseRejected(liveness: 'rejected', ktp: 'approved', selfie: 'approved');
    expect(history.rejectedItems, [KycRejectedItem.liveness]);
    expect(history.mustRetakeLiveness, true);
    expect(history.mustRetakeKtp, true);
    expect(history.mustRetakeSelfieKtp, false);
  });

  test('semua foto disetujui tapi status ditolak berarti data partner ditolak',
      () {
    final history =
        parseRejected(liveness: 'approved', ktp: 'approved', selfie: 'approved');
    expect(history.isPartnerDataRejected, true);
    expect(history.rejectedItems, [KycRejectedItem.partnerData]);
    expect(history.mustRetakeLiveness, false);
    expect(history.mustRetakeKtp, false);
    expect(history.mustRetakeSelfieKtp, false);
  });

  test('status foto rejected diabaikan bila pengajuan tidak berstatus rejected',
      () {
    final history = parseRejected(
        liveness: 'rejected',
        ktp: 'rejected',
        selfie: 'rejected',
        status: 'requested');
    expect(history.isRejected, false);
    expect(history.rejectedItems, isEmpty);
    expect(history.mustRetakeKtp, false);
  });
}
