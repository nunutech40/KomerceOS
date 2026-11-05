/// A text line and its position in the cropped KTP image.
class KtpOcrLine {
  const KtpOcrLine({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final String text;
  final double left;
  final double top;
  final double width;
  final double height;

  double get centerY => top + height / 2;
}
