import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/ideal_balance_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum WithdrawalBalanceNotice { ideal, pending, combined }

/// Figma's three blocked-balance variants for the withdrawal form.
class WithdrawalBalanceSheet extends StatelessWidget {
  const WithdrawalBalanceSheet({
    super.key,
    required this.notice,
    this.ideal,
  });

  final WithdrawalBalanceNotice notice;
  final IdealBalanceModel? ideal;

  String _money(num? value) =>
      CurrencyFormat.convertToIdrWithSpasi((value ?? 0).toInt(), 0);

  String get _title => switch (notice) {
        WithdrawalBalanceNotice.ideal => 'Saldo Tertahan sebagai\nSaldo Ideal',
        WithdrawalBalanceNotice.pending => 'Saldo Dalam Proses\nPenarikan',
        WithdrawalBalanceNotice.combined => 'Saldo Belum Dapat\nDigunakan',
      };

  String get _description => switch (notice) {
        WithdrawalBalanceNotice.ideal =>
          'Sebagian saldo kamu masih ditahan sebagai cadangan Saldo Ideal Komship.',
        WithdrawalBalanceNotice.pending =>
          'Menunggu withdrawal sebelumnya selesai.',
        WithdrawalBalanceNotice.combined =>
          'Saldo kamu belum bisa digunakan karena sedang diproses untuk penarikan dan tertahan sebagai Saldo Ideal Komship.',
      };

  Future<void> _openHelp() async {
    await launchUrl(
      Uri.parse(
          'https://bantuan.komerce.id/id/article/saldo-ideal-komship-7dn9vp/'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasIdeal = notice != WithdrawalBalanceNotice.pending;
    final media = MediaQuery.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * .82),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFDCDCDC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Stack(children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: Text(_title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.25)),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.grey600),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Text(_description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.grey600, height: 1.4)),
              if (hasIdeal) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    border: Border.all(color: AppColors.errorBase),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.errorBase, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const Text(
                                  'Saldo ideal diterapkan untuk menghindari saldo minus.',
                                  style: TextStyle(fontSize: 13, height: 1.35)),
                              InkWell(
                                  onTap: _openHelp,
                                  child: const Text('Pelajari lebih lanjut',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.infoBase,
                                          decoration:
                                              TextDecoration.underline))),
                            ])),
                      ]),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Darimana Saldo Ideal berasal?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                            'Potensi pendapatan order dikirim: ${_money(ideal?.inComeOrderPotential)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey600)),
                        Text(
                            'Potensi ongkir retur: ${_money(ideal?.shippingReturPotential)}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey600)),
                        const SizedBox(height: 4),
                        Text('Saldo Ideal: ${_money(ideal?.idealBalance)}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.errorBase)),
                      ]),
                ),
              ] else ...[
                const SizedBox(height: 24),
                SvgPicture.asset(
                    'assets/images/superapp/team/ic_proses_withdraw_saldo.svg',
                    width: 260,
                    height: 260),
              ],
              const SizedBox(height: 26),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.errorBase),
                child: const Text('Kembali'),
              ),
              const SizedBox(height: 8),
              DsButton(text: 'Tutup', onPressed: () => Navigator.pop(context)),
            ]),
          ),
        ),
      ),
    );
  }
}
