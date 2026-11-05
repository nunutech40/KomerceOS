import 'package:flutter/material.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_submission_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_identity_bottom_sheet.dart';

import 'kyc_liveness_flow.dart';

abstract final class KycResumeFlow {
  /// Called when the user taps KYC in Settings after the payment gate.
  static Future<void> openFromSettings(BuildContext context) =>
      _loadAndOpen(context, showIdentityIntro: true);

  /// Called after the identity intro shown by the payment flow.
  static Future<void> continueFromIdentity(BuildContext context) =>
      _loadAndOpen(context, showIdentityIntro: false);

  static Future<void> _loadAndOpen(BuildContext context,
      {required bool showIdentityIntro}) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final history =
          await locator<KycVerificationRepository>().latestHistory();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (history?.hasUploadedLiveness == true) {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => KycSubmissionPage(history: history),
        ));
      } else if (showIdentityIntro) {
        await KycIdentityBottomSheet.show<void>(context);
      } else {
        await KycLivenessFlow.start(context);
      }
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('Riwayat verifikasi gagal dimuat. Coba lagi.')));
    }
  }
}
