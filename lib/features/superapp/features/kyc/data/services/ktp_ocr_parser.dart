import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_ocr_data.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_ocr_line.dart';

/// Extracts conservative form candidates from the unstructured ML Kit output.
/// Missing or malformed fields stay empty rather than being guessed.
abstract final class KtpOcrParser {
  /// ML Kit may return the label and value in different blocks, with block
  /// order unrelated to their reading order. Rebuild visual rows first.
  static KtpOcrData parsePositionedLines(Iterable<KtpOcrLine> source) {
    final lines = source.where((line) => line.text.trim().isNotEmpty).toList()
      ..sort((a, b) => a.centerY.compareTo(b.centerY));
    final rows = <List<KtpOcrLine>>[];
    for (final line in lines) {
      if (rows.isNotEmpty &&
          rows.last.any((item) =>
              (item.centerY - line.centerY).abs() <=
              (item.height < line.height ? item.height : line.height) * .6)) {
        rows.last.add(line);
      } else {
        rows.add([line]);
      }
    }
    final ordered = rows.map((row) {
      row.sort((a, b) => a.left.compareTo(b.left));
      return row.map((line) => line.text).join(' ');
    }).toList();
    return parseLines(ordered, allowMixedCase: true);
  }

  static final _date = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})');
  static final _label = RegExp(
    r'^(?:NIK|NAMA|TEMPAT\s*[/, -]?\s*(?:TGL|TANGGAL)\s*LAHIR|'
    r'JENIS\s*KELAMIN|ALAMAT|RT\s*/\s*RW|KE(?:L)?\s*/\s*DESA|'
    r'KELURAHAN|DESA|KECAMATAN|AGAMA|STATUS\s*PERKAWINAN|'
    r'PEKERJAAN|KEWARGANEGARAAN|BERLAKU\s*HINGGA|PROVINSI|'
    r'KABUPATEN|KOTA|KODE\s*POS)\b',
  );

  static KtpOcrData parseLines(Iterable<String> source,
      {bool allowMixedCase = false}) {
    final lines = source
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? value(RegExp label, {bool requireKtpText = false}) {
      for (var i = 0; i < lines.length; i++) {
        final match = label.firstMatch(lines[i].toUpperCase());
        if (match == null) continue;
        final remainder = _clean(lines[i].substring(match.end));
        if (remainder.isNotEmpty) {
          if (!requireKtpText) return remainder;
          final candidate = _ktpText(remainder, allowMixedCase: allowMixedCase);
          if (candidate != null) return candidate;
          continue;
        }
        if (i + 1 < lines.length &&
            !_label.hasMatch(lines[i + 1].toUpperCase())) {
          final next = _clean(lines[i + 1]);
          if (!requireKtpText) return next;
          final candidate = _ktpText(next, allowMixedCase: allowMixedCase);
          if (candidate != null) return candidate;
        }
      }
      return null;
    }

    final rawNik = value(RegExp(r'^NIK\b'));
    final digits = rawNik?.replaceAll(RegExp(r'\D'), '');
    final nik = digits != null && digits.length == 16 ? digits : null;

    final placeAndDate = value(RegExp(
      r'^TEMPAT\s*[/, -]?\s*(?:TGL|TANGGAL)\s*LAHIR\b',
    ));
    final dateMatch =
        placeAndDate == null ? null : _date.firstMatch(placeAndDate);
    final birthDate = dateMatch == null ? null : _validDate(dateMatch);
    final rawBirthPlace = dateMatch == null
        ? null
        : _clean(placeAndDate!.substring(0, dateMatch.start));

    String? address;
    for (var i = 0; i < lines.length; i++) {
      final match = RegExp(r'^ALAMAT\b').firstMatch(lines[i].toUpperCase());
      if (match == null) continue;
      final parts = <String>[];
      final first = _clean(lines[i].substring(match.end));
      if (first.isNotEmpty) parts.add(first);
      for (var next = i + 1; next < lines.length && next <= i + 2; next++) {
        if (_label.hasMatch(lines[next].toUpperCase())) break;
        parts.add(lines[next]);
      }
      if (parts.isNotEmpty) {
        address = _ktpText(parts.join(' '), allowMixedCase: allowMixedCase);
      }
      break;
    }

    final rtRwRaw = value(RegExp(r'^RT\s*/\s*RW\b'));
    final rtRw = rtRwRaw == null
        ? null
        : RegExp(r'\b\d{1,3}\s*/\s*\d{1,3}\b')
            .firstMatch(rtRwRaw)
            ?.group(0)
            ?.replaceAll(' ', '');

    final postalRaw = value(RegExp(r'^KODE\s*POS\b'));
    final postalCode = postalRaw == null
        ? null
        : RegExp(r'\b\d{5}\b').firstMatch(postalRaw)?.group(0);

    return KtpOcrData(
      nik: nik,
      name: value(RegExp(r'^NAMA\b'), requireKtpText: true),
      birthPlace: _ktpText(rawBirthPlace, allowMixedCase: allowMixedCase),
      birthDate: birthDate,
      province: value(RegExp(r'^PROVINSI\b'), requireKtpText: true),
      city: value(RegExp(r'^(?:KABUPATEN|KOTA)\b'), requireKtpText: true),
      district: value(RegExp(r'^KECAMATAN\b'), requireKtpText: true),
      village: value(RegExp(r'^(?:KE(?:L)?\s*/\s*DESA|KELURAHAN|DESA)\b'),
          requireKtpText: true),
      address: address,
      rtRw: rtRw,
      postalCode: postalCode,
    );
  }

  static String _clean(String text) => text
      .replaceFirst(RegExp(r'^[\s:：.,-]+'), '')
      .replaceFirst(RegExp(r'[\s:：.,-]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// OCR capitalization is not reliable even when the KTP is printed in caps.
  /// The crop already excludes surrounding text, so normalize valid candidates.
  static String? _ktpText(String? text, {bool allowMixedCase = false}) {
    if (text == null) return null;
    final cleaned = _clean(text);
    final letters = RegExp(r'[A-Za-z]').allMatches(cleaned).length;
    if (letters < 4 ||
        (!allowMixedCase && cleaned != cleaned.toUpperCase()) ||
        _label.hasMatch(cleaned.toUpperCase())) {
      return null;
    }
    return cleaned.toUpperCase();
  }

  static String? _validDate(RegExpMatch match) {
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}
