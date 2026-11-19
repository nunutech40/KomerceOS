import 'package:flutter/material.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/kyc_history.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_rejected_bottom_sheet.dart';

/// Rejection reason popup shown before the user redoes a rejected part.
///
/// Returns true for "Ajukan Ulang Verifikasi", false for "Tutup" or dismiss.
/// The caller decides where "Tutup" leads (AC: the first popup returns to
/// Pengaturan, later popups stay on the last screen of the previous part).
abstract final class KycRejectionPrompt {
  static Future<bool> show(
    BuildContext context, {
    required KycHistory history,
    required KycRejectedItem item,
  }) async {
    final copy = _copy(item);
    final notes = history.notesFor(item);
    final result = await KycRejectedBottomSheet.show<bool>(
      context,
      title: copy.title,
      subtitle: copy.subtitle,
      descRejected: notes == null || notes.isEmpty ? copy.fallbackReason : notes,
      imagePath: copy.imagePath,
      onRetry: () => Navigator.of(context).pop(true),
      onClose: () => Navigator.of(context).pop(false),
    );
    return result == true;
  }

  static ({
    String title,
    String subtitle,
    String fallbackReason,
    String imagePath,
  }) _copy(KycRejectedItem item) {
    const dir = 'assets/images/superapp/kyc';
    return switch (item) {
      KycRejectedItem.liveness => (
          title: 'Verifikasi Wajah Ditolak',
          subtitle:
              'Verifikasi wajah kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
          fallbackReason: 'Verifikasi wajah belum memenuhi ketentuan.',
          imagePath: '$dir/ic_liveness_rejected.svg',
        ),
      KycRejectedItem.ktp => (
          title: 'Foto KTP Ditolak',
          subtitle:
              'Foto KTP kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
          fallbackReason: 'Foto KTP belum memenuhi ketentuan.',
          imagePath: '$dir/ic_ktp_rejected.svg',
        ),
      KycRejectedItem.selfieKtp => (
          title: 'Foto Selfie & KTP Ditolak',
          subtitle:
              'Foto selfie dengan KTP kamu belum sesuai. Mohon lakukan ulang dengan mengikuti panduan yang diberikan.',
          fallbackReason: 'Foto selfie dengan KTP belum memenuhi ketentuan.',
          imagePath: '$dir/ic_selfie_rejected.svg',
        ),
      KycRejectedItem.partnerData => (
          title: 'Data Partner Ditolak',
          subtitle:
              'Data partner kamu belum sesuai dengan dokumen. Mohon periksa dan perbaiki data partner.',
          fallbackReason: 'Data partner tidak sesuai dengan dokumen KTP.',
          imagePath: '$dir/ic_ktp_rejected.svg',
        ),
    };
  }
}
