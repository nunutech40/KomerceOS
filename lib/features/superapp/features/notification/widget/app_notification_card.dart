import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class AppNotificationCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? status;
  final Color? statusColor;
  final String date;
  final String time;
  final String message;
  final bool isRead;
  final VoidCallback? onTap;

  const AppNotificationCard({
    super.key,
    required this.leading,
    required this.title,
    this.status,
    this.statusColor,
    required this.date,
    required this.time,
    required this.message,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 4),
                  _buildDate(),
                  const SizedBox(height: 10),
                  _buildMessage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF222222),
          fontSize: 16,
        ),
        children: [
          TextSpan(text: title),
          if (status != null)
            TextSpan(
              text: ' - $status',
              style: TextStyle(
                color: statusColor ?? Colors.green,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDate() {
    return Row(
      children: [
        Text(
          date,
          style: AppTypography.bodyMdRegular.copyWith(
            color: AppColors.alwaysBlack,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.circle, size: 6,color: AppColors.alwaysBlack,),
        ),
        Text(
          time,
          style: AppTypography.bodyMdRegular.copyWith(
            color: AppColors.alwaysBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Text(
        message,
        style: AppTypography.bodyMdRegular.copyWith(
          color: AppColors.alwaysBlack,
        ),
      ),
    );
  }
}