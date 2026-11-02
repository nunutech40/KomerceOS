import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import '../../home/widgets/home_skeleton.dart';
import '../../kyc/widget/kyc_identity_bottom_sheet.dart';
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
/// - 5 = Paid Verification -> Badge Lanjutkan Verifikasi & KycOutlinedButton('Lanjutkan Verifikasi')
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
                  KycIdentityBottomSheet.show(context);
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