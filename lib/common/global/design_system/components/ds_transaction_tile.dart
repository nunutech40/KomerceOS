import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class DsTransactionItem {
  final String title;
  final String cardName;
  final String amount;
  final String date;

  const DsTransactionItem({
    required this.title,
    required this.cardName,
    required this.amount,
    required this.date,
  });
}

class DsTransactionTile extends StatelessWidget {
  final DsTransactionItem item;

  const DsTransactionTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyMdMedium.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_outlined,
                      size: 16,
                      color: Color(0xFF6E6E6E),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.cardName,
                      style: AppTypography.bodySmRegular.copyWith(
                        color: const Color(0xFF6E6E6E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: AppTypography.bodyMdSemiBold.copyWith(
                  color: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.date,
                style: AppTypography.bodySmRegular.copyWith(
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
