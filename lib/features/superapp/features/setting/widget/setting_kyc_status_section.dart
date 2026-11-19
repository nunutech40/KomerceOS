import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import '../../home/widgets/home_skeleton.dart';
import '../../kyc/domain/repositories/kyc_verification_repository.dart';
import '../../kyc/flow/kyc_resume_flow.dart';
import '../../kyc/widget/kyc_outlined_button.dart';
import '../../kyc/widget/kyc_status_badge.dart';
import '../../kyc/widget/kyc_success_bottom_sheet.dart';
import '../../kyc/widget/kyc_verification_bottom_sheet.dart';

/// Widget section untuk menampilkan status KYC dan action button terkait
/// berdasarkan parameter [verification_ktp_status] dari Superapp Profile (/api/v1/user/partner/get-profile-mobile):
/// - 0 = Belum Verifikasi -> Badge Belum Terverifikasi & KycOutlinedButton('Ajukan Verifikasi KTP')
/// - 1 = Dalam Proses -> Badge Dalam Proses & KycOutlinedButton HIDE
/// - 2 = Terverifikasi -> Badge Terverifikasi & KycOutlinedButton HIDE
/// - 3 = Verifikasi KTP Ditolak -> Badge Ditolak & KycOutlinedButton('Ajukan Ulang Verifikasi')
/// - 5 = Paid Verification -> cek latest-history:
///     - draft -> Badge Draft & KycOutlinedButton('Lanjutkan Verifikasi KTP')
///     - lainnya -> Badge Belum Terverifikasi & KycOutlinedButton('Ajukan Verifikasi KTP')
class SettingKycStatusSection extends StatelessWidget {
  final int? initialStatus;
  final bool showActionButton;

  const SettingKycStatusSection({
    super.key,
    this.initialStatus,
    this.showActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    int? blocStatus;
    try {
      blocStatus = context
          .watch<SuperappProfileBloc>()
          .state
          .displayProfile
          ?.verificationKtpStatus;
    } catch (_) {
      if (locator.isRegistered<SuperappProfileBloc>()) {
        blocStatus = locator<SuperappProfileBloc>()
            .state
            .displayProfile
            ?.verificationKtpStatus;
      }
    }

    final rawStatus = blocStatus ?? initialStatus;

    debugPrint(
        '[SettingKycStatusSection] Build - blocStatus: $blocStatus, rawStatus: $rawStatus');

    if (rawStatus == null) {
      return const SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: ShimmerBox(
              width: 140,
              height: 28,
              borderRadius: 100,
            ),
          ),
        ),
      );
    }

    final status = rawStatus;
    final ktpStatus = KycKtpStatus.fromValue(status);
    final isUnverified = ktpStatus == KycKtpStatus.unverified;
    final isRejected = ktpStatus == KycKtpStatus.rejected;
    final isPaid = ktpStatus == KycKtpStatus.paid;

    // Status 5 can mean "paid, not started" or a saved draft. Only
    // latest-history knows which, so that state loads it separately.
    if (isPaid) {
      return _PaidKycStatusSection(showActionButton: showActionButton);
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Badge status KYC:
          // Status 1 (Dalam proses) -> bisa diklik untuk buka info KycSuccessBottomSheet
          // Status 0 & 5 (Belum Verifikasi) -> tidak bisa diklik, aksi terpusat pada tombol "Ajukan Verifikasi KTP"
          // Status 3 (Ditolak) -> tidak bisa diklik, aksi terpusat pada tombol "Ajukan Ulang Verifikasi"
          KycStatusBadge.fromStatus(
            status,
            context: context,
            isClickable: ktpStatus == KycKtpStatus.inProgress,
            onTap: ktpStatus == KycKtpStatus.inProgress
                ? () =>
                    KycSuccessBottomSheet.showVerificationInProgress(context)
                : null,
          ),

          // Action Button: tampil jika showActionButton aktif dan status adalah unverified (0), rejected (3), atau paid (5)
          if (showActionButton && (isUnverified || isRejected || isPaid)) ...[
            const SizedBox(height: 12),
            KycOutlinedButton(
              text: isRejected
                  ? 'Ajukan Ulang Verifikasi'
                  : 'Ajukan Verifikasi KTP',
              showIcon: true,
              onClick: () {
                if (isPaid || isRejected) {
                  // Zero-fee skip rule: User yang sudah bayar (status 5) atau ditolak (status 3)
                  // langsung membuka alur pengisian identitas tanpa ditarik biaya Rp 25.000 lagi
                  KycResumeFlow.openFromSettings(context);
                } else {
                  // Status 0: Belum pernah bayar, tampilkan bottom sheet promosi & pembayaran Rp 25.000
                  KycVerificationBottomSheet.show(context);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Status 5 (sudah bayar). Membaca latest-history untuk membedakan draft
/// tersimpan dan pengajuan yang sudah dikirim (`requested`) dari pengajuan
/// yang belum dimulai. Setelah submit, profil BE (dev, 18 Nov 2026) masih
/// mengembalikan status 5, jadi `requested` ditampilkan sebagai Dalam Proses.
class _PaidKycStatusSection extends StatefulWidget {
  const _PaidKycStatusSection({required this.showActionButton});

  final bool showActionButton;

  @override
  State<_PaidKycStatusSection> createState() => _PaidKycStatusSectionState();
}

class _PaidKycStatusSectionState extends State<_PaidKycStatusSection> {
  bool _isDraft = false;
  bool _isRequested = false;

  @override
  void initState() {
    super.initState();
    KycResumeFlow.historyChanged.addListener(_loadDraftState);
    _loadDraftState();
  }

  @override
  void dispose() {
    KycResumeFlow.historyChanged.removeListener(_loadDraftState);
    super.dispose();
  }

  Future<void> _loadDraftState() async {
    if (!locator.isRegistered<KycVerificationRepository>()) return;
    try {
      final history =
          await locator<KycVerificationRepository>().latestHistory();
      if (!mounted) return;
      final status = history?.status?.toLowerCase();
      setState(() {
        _isDraft = status == 'draft';
        _isRequested = status == 'requested';
      });
    } catch (error) {
      // Badge tetap "Belum Terverifikasi" bila riwayat gagal dimuat.
      debugPrint('[SettingKycStatusSection] latest-history gagal: $error');
    }
  }

  Future<void> _open() => KycResumeFlow.openFromSettings(context);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          if (_isRequested)
            KycStatusBadge.fromStatus(
              KycKtpStatus.inProgress.value,
              context: context,
              isClickable: true,
              onTap: () =>
                  KycSuccessBottomSheet.showVerificationInProgress(context),
            )
          else if (_isDraft)
            KycStatusBadge.draft()
          else
            KycStatusBadge.fromStatus(KycKtpStatus.paid.value,
                context: context, isClickable: false),
          if (widget.showActionButton && !_isRequested) ...[
            const SizedBox(height: 12),
            KycOutlinedButton(
              text: _isDraft
                  ? 'Lanjutkan Verifikasi KTP'
                  : 'Ajukan Verifikasi KTP',
              showIcon: true,
              // Zero-fee skip rule: status 5 sudah bayar, langsung resume.
              onClick: _open,
            ),
          ],
        ],
      ),
    );
  }
}
