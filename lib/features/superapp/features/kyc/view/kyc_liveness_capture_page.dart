import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_liveness_sdk/flutter_liveness_sdk.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_face_guide_path.dart';

/// Figma-owned liveness page. The SDK supplies only the camera and face checks.
class KycLivenessCapturePage extends StatefulWidget {
  const KycLivenessCapturePage({super.key});

  @override
  State<KycLivenessCapturePage> createState() => _KycLivenessCapturePageState();
}

class _KycLivenessCapturePageState extends State<KycLivenessCapturePage> {
  EmbeddedLivenessSession? _session;
  StreamSubscription<LivenessEvent>? _events;
  int _completed = 0;
  LivenessStep? _step = LivenessStep.lookRight;
  String? _guidance = 'no_face';
  Timer? _successTimer;
  bool _showStepSuccess = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _events = FlutterLivenessSdk.events.listen((event) {
      if (!mounted || _closing) return;
      if (event.type == 'ready' ||
          event.type == 'stepPassed' ||
          event.type == 'guidance') {
        setState(() {
          _completed = event.completedCount ?? _completed;
          _step = event.step ?? _step;
          _guidance = event.type == 'guidance' ? event.code : null;
          if (event.type == 'stepPassed') {
            _showStepSuccess = true;
            _step = switch (event.step) {
              LivenessStep.lookRight => LivenessStep.lookLeft,
              LivenessStep.lookLeft => LivenessStep.smile,
              _ => _step,
            };
          }
        });
        if (event.type == 'stepPassed') {
          _successTimer?.cancel();
          _successTimer = Timer(const Duration(milliseconds: 1200), () {
            if (mounted && !_closing) {
              setState(() => _showStepSuccess = false);
            }
          });
        }
      }
    });
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      final session = await FlutterLivenessSdk.beginEmbedded(
        LivenessConfig(
          steps: const [
            LivenessStep.lookRight,
            LivenessStep.lookLeft,
            LivenessStep.smile,
          ],
          timeout: const Duration(seconds: 45),
        ),
      );
      if (!mounted || _closing) {
        await session.cancel();
        await session.dispose();
        return;
      }
      setState(() => _session = session);
      final result = await session.result;
      if (mounted && !_closing) {
        _closing = true;
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      if (mounted && !_closing) {
        _closing = true;
        Navigator.of(context).pop(const LivenessResult(
          status: LivenessStatus.failed,
          errorCode: 'camera_initialization_failed',
        ));
      }
    }
  }

  Future<void> _cancel() async {
    if (_closing) return;
    _closing = true;
    await _session?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    unawaited(_events?.cancel());
    if (!_closing) unawaited(_session?.cancel());
    unawaited(_session?.dispose());
    super.dispose();
  }

  String get _title {
    if (_guidance == 'no_face') return 'Wajah tidak terdeteksi';
    if (_guidance == 'multiple_faces') return 'Pastikan hanya ada satu wajah';
    return switch (_step) {
      LivenessStep.lookRight => 'Gelengkan kepala ke kanan',
      LivenessStep.lookLeft => 'Gelengkan kepala ke kiri',
      LivenessStep.smile => 'Hadap kamera dan senyum',
      LivenessStep.blink => 'Hadap kamera dan kedip',
      null => 'Pemeriksaan liveness',
    };
  }

  String get _hint {
    if (_guidance == 'no_face' || _guidance == 'multiple_faces') {
      return 'Pastikan hanya ada wajah Anda di layar dan pencahayaan yang cukup terang.';
    }
    return switch (_step) {
      LivenessStep.lookRight => 'Silakan gelengkan kepala ke arah kanan.',
      LivenessStep.lookLeft => 'Silakan gelengkan kepala ke arah kiri.',
      LivenessStep.smile => 'Silakan hadap kamera dan tersenyum.',
      LivenessStep.blink => 'Silakan hadap kamera dan kedipkan mata.',
      null => 'Jaga wajah tetap berada di dalam bingkai.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_cancel());
      },
      child: Scaffold(
        backgroundColor: AppColors.alwaysWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Pemeriksaan liveness',
                          style: AppTypography.bodySmRegular),
                    ),
                    Text('$_completed dari 3 selesai',
                        style: AppTypography.bodySmRegular.copyWith(
                          color: const Color(0xFF777777),
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                      3,
                      (index) => Expanded(
                            child: Container(
                              height: 5,
                              margin:
                                  EdgeInsets.only(right: index == 2 ? 0 : 7),
                              decoration: BoxDecoration(
                                color: index < _completed
                                    ? AppColors.primaryBase
                                    : const Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          )),
                ),
                const SizedBox(height: 20),
                Text(_title,
                    textAlign: TextAlign.center,
                    style: AppTypography.headingSm),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE9DB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_hint,
                              style: AppTypography.bodySmRegular.copyWith(
                                color: const Color(0xFF666666),
                              ))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: double.infinity,
                        height: math.min(
                          constraints.maxHeight,
                          constraints.maxWidth * 1.38,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ColoredBox(
                                color: const Color(0xFF343A34),
                                child: _session?.cameraView() ??
                                    const Center(
                                        child: CircularProgressIndicator(
                                      color: AppColors.primaryBase,
                                    )),
                              ),
                              IgnorePointer(
                                  child: CustomPaint(
                                painter: _LivenessCameraGuidePainter(),
                              )),
                              Positioned(
                                right: 18,
                                top: 20,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  child: _showStepSuccess
                                      ? Container(
                                          key: const ValueKey('step-success'),
                                          width: 32,
                                          height: 32,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primaryBase,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              const Positioned(
                                left: 12,
                                right: 12,
                                bottom: 16,
                                child: Text(
                                  'Jaga wajah tetap di dalam bingkai',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.center_focus_weak,
                        size: 16, color: Color(0xFF777777)),
                    SizedBox(width: 6),
                    Text('Gerakan akan terdeteksi otomatis',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF777777))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LivenessCameraGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orange = Paint()
      ..color = AppColors.primaryBase
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const inset = 12.0;
    const length = 17.0;
    const radius = 8.0;
    for (final x in [inset, size.width - inset]) {
      for (final y in [inset, size.height - inset]) {
        final dx = x == inset ? 1.0 : -1.0;
        final dy = y == inset ? 1.0 : -1.0;
        final path = Path()
          ..moveTo(x, y + dy * length)
          ..lineTo(x, y + dy * radius)
          ..quadraticBezierTo(x, y, x + dx * radius, y)
          ..lineTo(x + dx * length, y);
        canvas.drawPath(path, orange);
      }
    }
    // Figma's guide is a face silhouette: rounded forehead, broad cheeks,
    // then a narrower chin. Scale it with the visible camera card.
    final width = math.min(size.width * 0.44, 210.0);
    final top = size.height * 0.275;
    final bottom = size.height * 0.72;
    final path = buildKycFaceGuidePath(
      center: Offset(size.width / 2, (top + bottom) / 2),
      width: width,
      height: bottom - top,
    );
    final metrics = path.computeMetrics().first;
    final dash = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double start = 0; start < metrics.length; start += 10) {
      canvas.drawPath(metrics.extractPath(start, start + 6), dash);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
