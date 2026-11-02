import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liveness_sdk/flutter_liveness_sdk.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_camera_permission_dialog.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_cancel_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_liveness_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Connects the KYC screens to the local Flutter liveness plugin.
/// The plugin owns camera capture; KomerceOS owns the tutorial and draft.
abstract final class KycLivenessFlow {
  static Future<void> start(BuildContext context) async {
    final userId = locator<SuperappProfileBloc>().state.displayProfile?.id;
    if (userId == null) {
      _message(context, 'Profil belum siap. Coba lagi setelah profil dimuat.');
      return;
    }

    if (await _LivenessDraft.exists(userId)) {
      if (context.mounted) _showResult(context, userId);
      return;
    }
    if (!context.mounted) return;
    await KycLivenessBottomSheet.show<void>(
      context,
      onStart: () => unawaited(_beginCapture(context, userId)),
    );
  }

  static Future<void> _beginCapture(BuildContext context, int userId) async {
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
    }

    Navigator.pop(context); // Close the liveness tutorial.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    try {
      final result = await FlutterLivenessSdk.capture(
        LivenessConfig(
          steps: const [
            LivenessStep.lookRight,
            LivenessStep.lookLeft,
            LivenessStep.smile,
          ],
          timeout: const Duration(seconds: 45),
        ),
      );
      if (!context.mounted) return;
      switch (result.status) {
        case LivenessStatus.success:
          final selfiePath = result.selfiePath;
          if (selfiePath == null) {
            _message(
              context,
              'Foto hasil verifikasi tidak tersedia. Coba lagi.',
            );
            return;
          }
          await _LivenessDraft.save(userId, selfiePath);
          if (context.mounted) _showResult(context, userId);
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
    } on FileSystemException {
      if (context.mounted) {
        _message(
          context,
          'Foto verifikasi tidak dapat disimpan. Silakan coba lagi.',
        );
      }
    }
  }

  static void _showResult(BuildContext context, int userId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 72,
                color: Color(0xFFFF5C0A),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifikasi Wajah Berhasil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gerakan wajah berhasil diverifikasi. Foto disimpan sebagai draf lokal untuk integrasi KYC berikutnya.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  KycCancelBottomSheet.show<void>(
                    sheetContext,
                    onCancelSubmission: () {
                      Navigator.pop(sheetContext); // Confirmation.
                      unawaited(_cancelDraft(sheetContext, userId));
                    },
                  );
                },
                child: const Text('Batal'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C0A),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _cancelDraft(BuildContext context, int userId) async {
    await _LivenessDraft.delete(userId);
    if (context.mounted) Navigator.pop(context); // Result sheet.
  }

  static void _message(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

abstract final class _LivenessDraft {
  static String _key(int userId) => 'kyc_liveness_selfie_$userId';

  static Future<bool> exists(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key(userId));
    if (path == null) return false;
    if (await File(path).exists()) return true;
    await prefs.remove(_key(userId));
    return false;
  }

  static Future<void> save(int userId, String sourcePath) async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/kyc_drafts');
    await directory.create(recursive: true);
    final target = File('${directory.path}/liveness_$userId.jpg');
    await File(sourcePath).copy(target.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), target.path);
  }

  static Future<void> delete(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_key(userId));
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await prefs.remove(_key(userId));
  }
}
