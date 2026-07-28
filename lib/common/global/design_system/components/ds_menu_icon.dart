import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';

class DsMenuIcon extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onTap;

  const DsMenuIcon({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: icon,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMdMedium.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}