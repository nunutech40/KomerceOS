import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Baris informasi hak akses pada kartu anggota tim.
///
/// Menampilkan ikon perisai hijau, label "Akses:" beraksen hijau, lalu daftar
/// modul yang bisa diakses anggota (mis. "DASHBOARD, PRODUK, GUDANG, ...").
class TeamAccessRow extends StatelessWidget {
  final String accessLabel;

  const TeamAccessRow({super.key, required this.accessLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: DsAppImage(
              source: "assets/images/team/ic_lock.png", width: 15, height: 15),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Akses: ',
                  style: AppTypography.bodySmSemiBold.copyWith(
                    color: AppColors.successBase,
                  ),
                ),
                TextSpan(
                  text: accessLabel,
                  style: AppTypography.bodySmRegular.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
