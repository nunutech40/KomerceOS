/// KTP guide position in the camera preview's local logical pixels.
/// This is captured with the photo so the OCR crop matches the visible guide.
class KtpCaptureArea {
  const KtpCaptureArea({
    required this.viewportWidth,
    required this.viewportHeight,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double viewportWidth;
  final double viewportHeight;
  final double left;
  final double top;
  final double width;
  final double height;
}
