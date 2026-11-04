import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/kyc/view/kyc_submission_page.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_cancel_bottom_sheet.dart';
import 'package:komtim_partner/features/superapp/features/kyc/widget/kyc_ktp_guide_bottom_sheet.dart';

/// Liveness result page shown before the KTP tutorial sheet.
class KycLivenessResultPage extends StatefulWidget {
  const KycLivenessResultPage({super.key});

  @override
  State<KycLivenessResultPage> createState() => _KycLivenessResultPageState();
}

class _KycLivenessResultPageState extends State<KycLivenessResultPage> {
  void _showKtpGuide() {
    KycKtpGuideBottomSheet.show<void>(
      context,
      onStartPhoto: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const KycSubmissionPage(
            startWithKtpCamera: true,
          ),
        ));
      },
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _confirmCancel() {
    KycCancelBottomSheet.show<void>(
      context,
      onCancelSubmission: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.alwaysWhite,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 12, 35, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pemeriksaan liveness',
                        style: AppTypography.bodySmRegular),
                    const SizedBox(height: 8),
                    Row(
                        children: List.generate(
                            3,
                            (index) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        right: index < 2 ? 8 : 0),
                                    child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBase,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        )),
                                  ),
                                ))),
                    const SizedBox(height: 20),
                    const Center(
                        child: Text('Verifikasi Wajah Berhasil',
                            style: AppTypography.headingSm)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FAF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 22, color: Color(0xFF289568)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Semua gerakan berhasil direkam. Kamu bisa melanjutkan verifikasi identitas KTP.',
                              style: AppTypography.bodySmRegular.copyWith(
                                color: const Color(0xFF289568),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const DsAppImage(
                source:
                    'assets/images/superapp/topup/ilustration_top_up_success.svg',
                width: 246,
                height: 247,
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _confirmCancel,
                      child: const Text('Batal',
                          style: TextStyle(color: Color(0xFFFF3B30))),
                    ),
                    const SizedBox(height: 12),
                    DsButton(
                      text: 'Selanjutnya',
                      height: 46,
                      borderRadius: 10,
                      onPressed: _showKtpGuide,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
