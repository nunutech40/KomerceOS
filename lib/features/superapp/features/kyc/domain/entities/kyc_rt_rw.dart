/// RT/RW as stored by the backend: always `001/002` (3 digits each).
abstract final class KycRtRw {
  /// Normalizes user/OCR input to `000/000`, or returns null when the value
  /// cannot be read as an RT/RW pair.
  ///
  /// Accepts `2/3`, `02/03`, `RT 002 RW 003`, `002 / 003`, and `002003`.
  static String? normalize(String? input) {
    if (input == null) return null;
    final groups = RegExp(r'\d+')
        .allMatches(input)
        .map((match) => match.group(0)!)
        .toList();
    if (groups.length == 1 && groups.first.length == 6) {
      return '${groups.first.substring(0, 3)}/${groups.first.substring(3)}';
    }
    if (groups.length != 2 || groups.any((group) => group.length > 3)) {
      return null;
    }
    return groups.map((group) => group.padLeft(3, '0')).join('/');
  }
}
