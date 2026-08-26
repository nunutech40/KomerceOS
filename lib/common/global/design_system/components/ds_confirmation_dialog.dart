import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_radius.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class DsConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? icon;
  final Color? confirmColor;

  const DsConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.confirmColor,
  });

  /// Helper statis untuk memanggil dialog secara bersih dari parent page
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? icon,
    Color? confirmColor,
  }) {
    return showDialog(
      context: context,
      builder: (_) => DsConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        icon: icon,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCancelButton = cancelText != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Default/Custom
            icon ??
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color:
                      AppColors.warningBase, // Menggunakan token warna warning
                ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headingXs
                  .copyWith(color: AppColors.alwaysBlack),
            ),

            const SizedBox(height: 8),

            // Message Body
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMdRegular
                  .copyWith(color: AppColors.textDark),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (hasCancelButton) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          color: AppColors.alwaysBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? AppColors.primaryBase,
                      foregroundColor: AppColors.alwaysWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
