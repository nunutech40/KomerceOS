import '../../domain/entities/kyc_history.dart';

class KycHistoryResponse {
  const KycHistoryResponse._();

  static KycHistory? parse(dynamic body) {
    if (body is! Map) throw const FormatException('Invalid KYC history');
    final data = body['data'];
    if (data == null) return null;
    if (data is! Map) throw const FormatException('Invalid KYC history data');
    Map? picture(String key) => data[key] is Map ? data[key] as Map : null;
    String? field(Map? source, String key) {
      final raw = source?[key];
      if (raw == null) return null;
      final value = raw.toString().trim();
      return value.isEmpty ? null : value;
    }

    final partner = data['info_data_partner'];
    final values = <String, String>{};
    if (partner is Map) {
      for (final key in const [
        'nik',
        'name',
        'email',
        'phone',
        'birth_place',
        'birth_date',
        'province',
        'city',
        'district',
        'village',
        'address',
        'rt_rw',
        'pos_code',
      ]) {
        final value = field(partner, key);
        if (value != null) values[key] = value;
      }
    }
    final liveness = picture('liveness_picture');
    final ktp = picture('ktp_picture');
    final selfie = picture('ktp_face_picture');
    return KycHistory(
      livenessStatus: field(liveness, 'status'),
      livenessUrl: field(liveness, 'url'),
      ktpStatus: field(ktp, 'status'),
      ktpUrl: field(ktp, 'url'),
      selfieKtpStatus: field(selfie, 'status'),
      selfieKtpUrl: field(selfie, 'url'),
      partnerData: values,
    );
  }
}
