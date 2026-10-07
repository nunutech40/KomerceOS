import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../domain/entities/bank_account_entry.dart';

class BankLiabilitySheet extends StatefulWidget {
  const BankLiabilitySheet({super.key, required this.liabilities});

  final List<BankLiability> liabilities;

  @override
  State<BankLiabilitySheet> createState() => _BankLiabilitySheetState();
}

class _BankLiabilitySheetState extends State<BankLiabilitySheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String _rupiah(int balance) {
    final digits = balance.abs().toString();
    final formatted = digits.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return '-Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _reason.text.trim().length >= 10;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgPopup,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text('Rekeningmu Sudah\nTerdaftar di Akun Lain',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingXs),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Komerce-mu yang lain masih ada tanggungan saldo minus.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmRegular
                    .copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.alwaysWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(child: Text('Email')),
                        Text('Kewajiban Top up'),
                      ]),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 176),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.liabilities.length,
                        itemBuilder: (_, index) {
                          final item = widget.liabilities[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            child: Row(children: [
                              Expanded(
                                child: Text(item.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmRegular
                                        .copyWith(color: AppColors.errorBase)),
                              ),
                              Text(_rupiah(item.balance),
                                  style: AppTypography.bodySmRegular
                                      .copyWith(color: AppColors.errorBase)),
                            ]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Bayar tanggungan dahulu untuk lanjut tambah rekening.',
                    style: AppTypography.bodySmRegular),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Alasan Penambahan Rekening*',
                    style: AppTypography.bodySmMedium),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reason,
                maxLines: 3,
                maxLength: 255,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Tulis alasanmu minimal 10 karakter',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: canSubmit
                    ? () => Navigator.of(context).pop(_reason.text.trim())
                    : null,
                child: const Text('Kirim Alasan & Ajukan'),
              ),
              const SizedBox(height: 8),
              DsButton(
                text: 'Selesaikan Tanggungan',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
