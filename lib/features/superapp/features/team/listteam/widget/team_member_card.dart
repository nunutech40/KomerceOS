import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/team/listteam/widget/dash_line_team.dart';
import 'package:komtim_partner/features/superapp/features/team/listteam/widget/team_access_row.dart';

import '../model/team_member_model.dart';
import 'team_role_tag.dart';

/// Kartu satu anggota tim pada halaman Daftar Tim.
///
/// Menampilkan avatar, nama (+ badge terverifikasi), email, tag peran atau
/// tombol menu (…), serta baris hak akses.
class TeamMemberCard extends StatelessWidget {
  final TeamMemberModel member;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const TeamMemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md3),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.circular),
              child: DsAppImage(
                source: member.avatarUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Semua konten di kanan avatar (nama, email, dashed line, akses)
            // berbagi lebar yang SAMA lewat Expanded ini. _Trailing sengaja
            // ditaruh di dalam Row baris pertama saja (sejajar nama), supaya
            // dashed line & akses TIDAK ikut menyempit gara-gara lebar
            // _Trailing (mis. saat tag "Talent Acquisition" panjang).
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                member.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMdSemiBold.copyWith(
                                  color: AppColors.grey800,
                                ),
                              ),
                            ),
                            if (member.isVerified) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(
                                Icons.verified_rounded,
                                size: AppSpacing.iconSm,
                                color: AppColors.secondaryBase,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Trailing(role: member.role, onMenuTap: onMenuTap),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    member.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmRegular.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md3),
                  const DashedLine(dashWidth: 6, dashGap: 4),
                  const SizedBox(height: AppSpacing.md3),
                  TeamAccessRow(accessLabel: member.accessLabel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bagian kanan header kartu: tag peran bila ada, jika tidak tombol menu (…).
class _Trailing extends StatelessWidget {
  final String? role;
  final VoidCallback? onMenuTap;

  const _Trailing({required this.role, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final role = this.role;
    if (role != null && role.isNotEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 130),
        child: TeamRoleTag(role: role),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.circular),
      onTap: onMenuTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: AppSpacing.iconMd,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}
