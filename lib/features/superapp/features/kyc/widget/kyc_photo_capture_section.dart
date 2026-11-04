import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_face_guide_path.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permendagri 72/2022: KTP-el blank measures 85.60 × 53.98 mm.
const double _ktpAspectRatio = 85.60 / 53.98;

/// Live camera area shared by the KTP and selfie-with-KTP steps.
class KycPhotoCaptureSection extends StatefulWidget {
  const KycPhotoCaptureSection({
    super.key,
    required this.selfie,
    required this.capturedPath,
    required this.onCaptured,
    required this.onBusyChanged,
    required this.onError,
  });

  final bool selfie;
  final String? capturedPath;
  final ValueChanged<String> onCaptured;
  final ValueChanged<bool> onBusyChanged;
  final ValueChanged<String> onError;

  @override
  State<KycPhotoCaptureSection> createState() => KycPhotoCaptureSectionState();
}

class KycPhotoCaptureSectionState extends State<KycPhotoCaptureSection>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _busy = false;
  bool _disposed = false;
  bool _hasStarted = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && _controller != null) {
      unawaited(_releaseCamera());
    } else if (state == AppLifecycleState.resumed &&
        _hasStarted &&
        widget.capturedPath == null &&
        _controller == null) {
      unawaited(startCamera());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_releaseCamera());
    super.dispose();
  }

  void _setBusy(bool value) {
    if (_disposed || !mounted) return;
    setState(() => _busy = value);
    widget.onBusyChanged(value);
  }

  Future<void> _releaseCamera() async {
    _generation++;
    final previous = _controller;
    _controller = null;
    if (mounted && !_disposed) setState(() {});
    if (previous != null) await previous.dispose();
  }

  Future<void> startCamera() async {
    if (_disposed || _busy || widget.capturedPath != null) return;
    _hasStarted = true;
    _setBusy(true);
    final request = ++_generation;
    CameraController? next;
    try {
      final permission = await Permission.camera.request();
      if (_disposed || request != _generation) return;
      if (!permission.isGranted) {
        widget.onError(
            'Izin kamera ditolak. Aktifkan izin kamera di Pengaturan.');
        return;
      }
      final cameras = await availableCameras();
      if (_disposed || request != _generation) return;
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'Kamera tidak tersedia');
      }
      final direction =
          widget.selfie ? CameraLensDirection.front : CameraLensDirection.back;
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == direction,
        orElse: () => cameras.first,
      );
      next = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await next.initialize();
      if (_disposed || request != _generation) {
        await next.dispose();
        return;
      }
      final previous = _controller;
      setState(() => _controller = next);
      if (previous != null) await previous.dispose();
    } on CameraException catch (error) {
      if (!_disposed) {
        widget.onError(
          error.code == 'CameraAccessDenied'
              ? 'Izin kamera ditolak. Aktifkan izin kamera di Pengaturan.'
              : 'Kamera tidak dapat dibuka. Coba lagi.',
        );
      }
      if (next != null) await next.dispose();
    } catch (_) {
      if (!_disposed) widget.onError('Kamera tidak dapat dibuka. Coba lagi.');
      if (next != null) await next.dispose();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> takePhoto() async {
    if (_busy || _disposed) return;
    final camera = _controller;
    if (camera == null || !camera.value.isInitialized) {
      await startCamera();
      return;
    }
    _setBusy(true);
    try {
      final image = await camera.takePicture();
      if (_disposed || !mounted) return;
      widget.onCaptured(image.path);
      await _releaseCamera();
    } on CameraException {
      if (!_disposed) widget.onError('Foto belum berhasil diambil. Coba lagi.');
    } finally {
      _setBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _controller;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AspectRatio(
        aspectRatio: 0.70,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.capturedPath != null)
              Image.file(File(widget.capturedPath!), fit: BoxFit.cover)
            else if (camera != null && camera.value.isInitialized)
              _CameraFeed(controller: camera)
            else
              const ColoredBox(color: Color(0xFF4C5148)),
            if (widget.capturedPath == null) ...[
              CustomPaint(painter: _CaptureGuidePainter(selfie: widget.selfie)),
              if (_busy)
                const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              if (camera == null && !_busy)
                const Positioned(
                  bottom: 20,
                  left: 12,
                  right: 12,
                  child: Text(
                    'Kamera belum aktif. Ketuk Ambil Gambar untuk mencoba lagi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CaptureGuidePainter extends CustomPainter {
  const _CaptureGuidePainter({required this.selfie});

  final bool selfie;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (selfie) {
      final face = buildKycFaceGuidePath(
        center: Offset(size.width * .55, size.height * .43),
        width: size.width * .48,
        height: size.height * .48,
      );
      _drawDashed(canvas, face, paint);
      final ktpWidth = size.width * .36;
      final ktp = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .06, size.height * .66, ktpWidth,
            ktpWidth / _ktpAspectRatio),
        const Radius.circular(5),
      );
      _drawDashed(canvas, Path()..addRRect(ktp), paint);
    } else {
      final ktpWidth = size.width * .78;
      final ktp = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * .5, size.height * .5),
          width: ktpWidth,
          height: ktpWidth / _ktpAspectRatio,
        ),
        const Radius.circular(8),
      );
      canvas.drawRRect(ktp, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
            metric.extractPath(
                distance, (distance + 7).clamp(0, metric.length)),
            paint);
        distance += 13;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CaptureGuidePainter oldDelegate) =>
      oldDelegate.selfie != selfie;
}

class _CameraFeed extends StatelessWidget {
  const _CameraFeed({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize!;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}
