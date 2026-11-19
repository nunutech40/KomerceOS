import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_rt_rw.dart';

void main() {
  test('RT/RW dinormalisasi ke format 001/002', () {
    expect(KycRtRw.normalize('001/002'), '001/002');
    expect(KycRtRw.normalize('02/03'), '002/003');
    expect(KycRtRw.normalize('2/3'), '002/003');
    expect(KycRtRw.normalize(' 003 / 002 '), '003/002');
    expect(KycRtRw.normalize('RT 003 RW 002'), '003/002');
    expect(KycRtRw.normalize('003002'), '003/002');
  });

  test('RT/RW yang tidak bisa dibaca ditolak', () {
    expect(KycRtRw.normalize(null), isNull);
    expect(KycRtRw.normalize(''), isNull);
    expect(KycRtRw.normalize('003'), isNull);
    expect(KycRtRw.normalize('0003/002'), isNull);
    expect(KycRtRw.normalize('1/2/3'), isNull);
  });
}
