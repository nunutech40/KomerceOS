import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class TeamActionRequiredSection extends StatelessWidget {
  final int invoiceCount;
  final int shoppingCount;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onShoppingTap;

  const TeamActionRequiredSection({
    Key? key,
    required this.invoiceCount,
    required this.shoppingCount,
    this.onInvoiceTap,
    this.onShoppingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasInvoice = invoiceCount > 0;
    bool hasShopping = shoppingCount > 0;

    String titleText = 'Perlu Tindakan';
    String descText = '';
    String iconPath = 'assets/images/team/ic_notification_alert.svg';

    if (hasInvoice && hasShopping) {
      descText =
          'Terdapat tagihan dan pengajuan yang membutuhkan perhatian Anda';
    } else if (hasInvoice && !hasShopping) {
      descText = 'Terdapat tagihan yang membutuhkan perhatian Anda';
    } else if (!hasInvoice && hasShopping) {
      descText = 'Terdapat pengajuan yang membutuhkan perhatian Anda';
    } else {
      titleText = 'Tidak Ada Tindakan';
      descText =
          'Tidak ada invoice maupun pengajuan yang perlu ditindaklanjuti.';
      iconPath = 'assets/images/team/ic_success_notification.png';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBadgeBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primaryBase.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBase.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsAppImage(
                source: iconPath,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: AppTypography.bodyMdSemiBold.copyWith(
                        color: AppColors.primaryBase,
                      ),
                    ),
                    Text(
                      descText,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.grey200),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onInvoiceTap,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        invoiceCount == 0 ? '-' : '$invoiceCount',
                        style: AppTypography.headingLg.copyWith(
                          color: AppColors.primaryBase,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice',
                              style: AppTypography.bodySmSemiBold.copyWith(
                                color: AppColors.alwaysBlack,
                              ),
                            ),
                            Text(
                              'belum dibayar',
                              style: AppTypography.bodySmRegular.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.grey200,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              Expanded(
                child: InkWell(
                  onTap: onShoppingTap,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        shoppingCount == 0 ? '-' : '$shoppingCount',
                        style: AppTypography.headingLg.copyWith(
                          color: AppColors.primaryBase,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Belanja',
                              style: AppTypography.bodySmSemiBold.copyWith(
                                color: AppColors.alwaysBlack,
                              ),
                            ),
                            Text(
                              'menunggu ACC',
                              style: AppTypography.bodySmRegular.copyWith(
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
