import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_ocr_parser.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_ocr_line.dart';

void main() {
  test('label dan isi di blok OCR terpisah dibaca menurut posisi kartu', () {
    const line = KtpOcrLine.new;
    final result = KtpOcrParser.parsePositionedLines([
      line(text: 'Rilas Test', left: 90, top: 50, width: 120, height: 14),
      line(
          text: 'Bandung, 12-02-1991',
          left: 90,
          top: 70,
          width: 170,
          height: 14),
      line(text: '1234567890123456', left: 90, top: 30, width: 160, height: 14),
      line(text: 'Nama', left: 0, top: 51, width: 45, height: 14),
      line(text: 'Tempat/Tgl Lahir', left: 0, top: 71, width: 80, height: 14),
      line(text: 'NIK', left: 0, top: 31, width: 30, height: 14),
    ]);

    expect(result.nik, '1234567890123456');
    expect(result.name, 'RILAS TEST');
    expect(result.birthPlace, 'BANDUNG');
    expect(result.birthDate, '12/02/1991');
  });

  test('membaca kandidat field KTP dari teks OCR', () {
    final result = KtpOcrParser.parseLines([
      'PROVINSI JAWA TENGAH',
      'KABUPATEN BANYUMAS',
      'NIK : 1234567890123456',
      'Nama : RILAS TEST',
      'Tempat/Tgl Lahir : BANDUNG, 12-02-1991',
      'Alamat : JL. CONTOH NO. 1',
      'RT/RW : 004/002',
      'Kel/Desa : LARLUK',
      'Kecamatan : MREBET',
    ]);

    expect(result.nik, '1234567890123456');
    expect(result.name, 'RILAS TEST');
    expect(result.birthPlace, 'BANDUNG');
    expect(result.birthDate, '12/02/1991');
    expect(result.province, 'JAWA TENGAH');
    expect(result.city, 'BANYUMAS');
    expect(result.address, 'JL. CONTOH NO. 1');
    expect(result.rtRw, '004/002');
    expect(result.village, 'LARLUK');
    expect(result.district, 'MREBET');
    expect(result.postalCode, isNull);
  });

  test('label terpisah bisa dibaca tanpa mengarang data yang tidak valid', () {
    final result = KtpOcrParser.parseLines([
      'NIK',
      '123456789012345',
      'NAMA',
      'PENGGUNA CONTOH',
      'Tempat/Tgl Lahir: BANDUNG, 31/02/1991',
      'Alamat : JALAN CONTOH',
      'BLOK A NOMOR 2',
      'RT/RW : 001/002',
    ]);

    expect(result.nik, isNull);
    expect(result.name, 'PENGGUNA CONTOH');
    expect(result.birthDate, isNull);
    expect(result.address, 'JALAN CONTOH BLOK A NOMOR 2');
  });

  test('teks sekitar kartu tidak dianggap sebagai alamat dan kecamatan', () {
    final result = KtpOcrParser.parseLines([
      'PROVINSI JAWA TENGAH',
      'KABUPATEN PURBALINGGA',
      'KECAMATAN',
      'fn',
      'ALAMAT',
      'Ke/Desa caps lock',
      'KEL/DESA KALIMANAH KULON',
    ]);

    expect(result.province, 'JAWA TENGAH');
    expect(result.city, 'PURBALINGGA');
    expect(result.district, isNull);
    expect(result.address, isNull);
    expect(result.village, 'KALIMANAH KULON');
  });
}
