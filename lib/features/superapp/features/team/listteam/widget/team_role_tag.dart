import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Tag peran anggota tim (mis. "Talent Acquisition", "Advertiser").
///
/// Warna latar & teks dipilih otomatis berdasarkan nama peran agar konsisten
/// dengan desain: beberapa peran memakai aksen biru/hijau/pink, sisanya oranye.
class TeamRoleTag extends StatelessWidget {
  final String role;

  const TeamRoleTag({super.key, required this.role});

  _RoleColor get _color => _resolveColor(role);

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(AppRadius.md3),
      ),
      child: Text(
        role,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelXsMedium.copyWith(color: color.foreground),
      ),
    );
  }

  /// Memetakan nama peran ke pasangan warna latar & teks.
  static _RoleColor _resolveColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin marketplace':
        return const _RoleColor(
          background: AppColors.secondaryLight,
          foreground: AppColors.secondaryBase,
        );
      case 'advertiser':
        return const _RoleColor(
          background: AppColors.successLight,
          foreground: AppColors.successBase,
        );
      case 'live streamer':
        return const _RoleColor(
          background: Color(0xFFFDE7F1),
          foreground: Color(0xFFE5397E),
        );
      default:
        // Default aksen oranye (Talent Acquisition, UIUX Designer, dll).
        return const _RoleColor(
          background: AppColors.primaryLight,
          foreground: AppColors.primaryBase,
        );
    }
  }
}

/// Pasangan warna latar & teks untuk sebuah tag peran.
class _RoleColor {
  final Color background;
  final Color foreground;

  const _RoleColor({required this.background, required this.foreground});
}
