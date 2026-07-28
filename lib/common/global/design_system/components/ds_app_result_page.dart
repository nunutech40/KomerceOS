import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class DsAppResultPage extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String? description;
  final Widget? action;
  final Widget? secondaryAction;
  final EdgeInsetsGeometry padding;

  const DsAppResultPage({
    super.key,
    required this.illustration,
    required this.title,
    this.description,
    this.action,
    this.secondaryAction,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.pageMargin,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMdSemiBold.copyWith(
                    color: AppColors.alwaysBlack,
                  ),
                ),
            
                const SizedBox(height: AppSpacing.sm),
                
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
            
                const SizedBox(height: AppSpacing.lg),
                
                illustration,
            
                const SizedBox(height: AppSpacing.xl),
            
                if (action != null) ...[
                  SizedBox(width: double.infinity, child: action!),
                ],
            
                if (secondaryAction != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(width: double.infinity, child: secondaryAction!),
                ],
            
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}