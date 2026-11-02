import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Shared layout for the bank and reason success frames in Sprint 3.
class BankResultSheet extends StatelessWidget {
  const BankResultSheet({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73000000),
      builder: (_) => BankResultSheet(title: title, description: description),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - media.viewInsets.bottom;
    final bottomPadding = math.max(40.0, media.padding.bottom);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: double.infinity,
        height: math.min(615.0, availableHeight),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.bgPopup,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border:
              Border.fromBorderSide(BorderSide(color: AppColors.alwaysWhite)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.headingMd.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox.square(
                            dimension: 40,
                            child: Material(
                              color: AppColors.bgLight,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Tutup',
                                iconSize: 20,
                                color: AppColors.grey700,
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMdRegular
                          .copyWith(color: AppColors.grey600),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SvgPicture.asset(
                      'assets/images/superapp/auth/success_reset_password.svg',
                      width: 223.4,
                      height: 300,
                      semanticsLabel: title.replaceAll('\n', ' '),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Spacer(),
                    DsButton(
                      text: 'Oke',
                      height: 44,
                      borderRadius: AppRadius.md,
                      textStyle: AppTypography.bodyMdRegular,
                      elevation: 0,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
