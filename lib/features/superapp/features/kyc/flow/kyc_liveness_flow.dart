import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liveness_sdk/flutter_liveness_sdk.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_camera_permission_dialog.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_liveness_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_liveness_result_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_liveness_capture_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connects the KYC screens to the local Flutter liveness plugin.
/// Android renders the capture page in the app while the SDK owns detection.
abstract final class KycLivenessFlow {
  static Future<void> start(BuildContext context) async {
    await _removeLegacyLivenessCache();
    if (!context.mounted) return;
    await KycLivenessBottomSheet.show<void>(
      context,
      onStart: () => unawaited(_beginCapture(context)),
    );
  }

  static Future<void> _beginCapture(BuildContext context) async {
    bool granted = false;
    try {
      granted = (await Permission.camera.status).isGranted;
    } on PlatformException {
      // The native SDK still requests the OS permission when capture begins.
    }
    if (!context.mounted) return;

    if (!granted) {
      final allowed = await KycCameraPermissionDialog.show<bool>(
        context,
        onAllow: () => Navigator.pop(context, true),
        onDeny: () => Navigator.pop(context, false),
      );
      if (allowed != true || !context.mounted) return;
      granted = (await Permission.camera.request()).isGranted;
      if (!granted || !context.mounted) return;
    }

    Navigator.pop(context); // Close the liveness tutorial.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    try {
      LivenessResult? result;
      if (Platform.isAndroid) {
        result = await Navigator.of(context).push<LivenessResult>(
          MaterialPageRoute(
            builder: (_) => const KycLivenessCapturePage(),
          ),
        );
      } else {
        result = await FlutterLivenessSdk.capture(
          LivenessConfig(
            steps: const [
              LivenessStep.lookRight,
              LivenessStep.lookLeft,
              LivenessStep.smile,
            ],
            timeout: const Duration(seconds: 45),
          ),
        );
      }
      if (!context.mounted) return;
      if (result == null) return;
      switch (result.status) {
        case LivenessStatus.success:
          final imagePath = result.selfiePath;
          if (imagePath == null || imagePath.isEmpty) {
            _message(context, 'Foto liveness tidak tersedia. Coba lagi.');
            return;
          }
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          try {
            await locator<KycVerificationRepository>()
                .upload(livenessPath: imagePath);
          } catch (_) {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              _message(context, 'Upload liveness gagal. Coba lagi.');
            }
            return;
          }
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).pop();
          _showResult(context);
          return;
        case LivenessStatus.cancelled:
          return;
        case LivenessStatus.timedOut:
          _message(context, 'Waktu verifikasi wajah habis. Silakan coba lagi.');
          return;
        case LivenessStatus.failed:
          if (result.errorCode == 'camera_permission_denied') {
            await KycCameraDeniedDialog.show<void>(
              context,
              onSettings: () {
                Navigator.pop(context);
                unawaited(openAppSettings());
              },
            );
          } else {
            _message(context, 'Verifikasi wajah gagal. Silakan coba lagi.');
          }
          return;
      }
    } on PlatformException {
      if (context.mounted) {
        _message(context, 'Kamera tidak dapat dibuka. Silakan coba lagi.');
      }
    }
  }

  static void _showResult(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const KycLivenessResultPage(),
    ));
  }

  static void _message(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _removeLegacyLivenessCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs
          .getKeys()
          .where((key) => key.startsWith('kyc_liveness_selfie_'))
          .toList()) {
        await prefs.remove(key);
      }
      final root = await getApplicationSupportDirectory();
      final directory = Directory('${root.path}/kyc_drafts');
      if (await directory.exists()) await directory.delete(recursive: true);
    } on Exception {
      // An old cache failure must not block a fresh liveness attempt.
    }
  }
}
