import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

import 'email_check_status.dart';
import 'email_status_row.dart';
import 'email_submit_button.dart';

// -----------------------------------------------------------------------------
// EmailCheckCard
//
// Container card yang berisi:
//   - EmailInputField  → input email dengan validasi inline
//   - EmailStatusRow   → baris status (loading / found / unregistered)
//   - EmailSubmitButton → tombol "Lanjutkan"
//
// Tidak ada logika bisnis — hanya presentasi.
// -----------------------------------------------------------------------------

class EmailCheckCard extends StatelessWidget {
  final TextEditingController emailController;
  final EmailCheckStatus status;
  final String? inlineError;
  final bool isButtonActive;
  final bool isLoading;
  final VoidCallback onSubmit;

  const EmailCheckCard({
    super.key,
    required this.emailController,
    required this.status,
    required this.inlineError,
    required this.isButtonActive,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg2),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Email input field ---
          DsEmailInput(
            label: 'Email',
            controller: emailController,
            errorText: inlineError,
          ),

          // --- Status row — hanya muncul saat found atau unregistered ---
          if (status == EmailCheckStatus.found ||
              status == EmailCheckStatus.unregistered) ...[
            const SizedBox(height: AppSpacing.sm),
            EmailStatusRow(status: status),
          ],

          const SizedBox(height: AppSpacing.xl),

          // --- Tombol Lanjutkan ---
          EmailSubmitButton(
            status: status,
            isActive: isButtonActive,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
