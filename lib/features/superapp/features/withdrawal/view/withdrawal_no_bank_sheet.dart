import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

/// Popup prasyarat rekening, dipakai dari Home dan dari pemilih rekening form.
class WithdrawalNoBankSheet {
  const WithdrawalNoBankSheet._();

  static Future<bool?> show(BuildContext context) => DsBottomSheet.show<bool>(
        context: context,
        title: 'Kamu Belum Menambahkan Rekening',
        titleStyle: AppTypography.headingXs,
        description:
            'Tambahkan rekening terlebih dahulu agar kamu bisa melakukan penarikan saldo.',
        image: SvgPicture.asset(
          'assets/images/superapp/setting/bank_account_empty.svg',
          width: 243,
          height: 220,
        ),
        secondaryButtonText: 'Kembali',
        secondaryButtonColor: AppColors.errorBase,
        onSecondaryPressed: () => Navigator.of(context).pop(false),
        primaryButtonText: 'Tambah Sekarang',
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        barrierColor: const Color(0x73000000),
      );
}
