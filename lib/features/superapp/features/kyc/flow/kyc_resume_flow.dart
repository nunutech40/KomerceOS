import 'package:flutter/material.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/kyc_verification_repository.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_submission_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_identity_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_success_bottom_sheet.dart';

import 'kyc_liveness_flow.dart';
import 'kyc_rejection_prompt.dart';

abstract final class KycResumeFlow {
  /// Bumped whenever the server KYC history changes (draft saved or
  /// submission sent) so status widgets can reload `latest-history`.
  static final ValueNotifier<int> historyChanged = ValueNotifier<int>(0);

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
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 14),
                  Text('Memuat riwayat verifikasi...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      final history =
          await locator<KycVerificationRepository>().latestHistory();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (history?.isRequested == true) {
        await KycSuccessBottomSheet.showVerificationInProgress(context);
      } else if (history != null && history.isRejected) {
        await _openRejected(context, history);
      } else if (history?.hasUploadedLiveness == true) {
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

  /// Rejected submission: show the first rejection reason, then redo only
  /// the parts the AC hierarchy requires (see [KycHistory.mustRetakeKtp]).
  /// "Tutup" on this first popup keeps the user on Pengaturan.
  static Future<void> _openRejected(
      BuildContext context, KycHistory history) async {
    final first = history.rejectedItems.first;
    final retry = await KycRejectionPrompt.show(context,
        history: history, item: first);
    if (!retry || !context.mounted) return;
    if (history.mustRetakeLiveness) {
      await KycLivenessFlow.start(context, rejectedHistory: history);
    } else {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => KycSubmissionPage(history: history),
      ));
    }
  }
}
