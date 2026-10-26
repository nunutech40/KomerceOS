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

  bool get _hasReasonInput => _reason.text.trim().isNotEmpty;
  bool get _isReasonValid => _reason.text.trim().length >= 10;

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
    final canSubmit = _isReasonValid;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.insetLg,
        AppSpacing.xl,
        AppSpacing.insetLg,
        AppSpacing.insetLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgPopup,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
                    child: Text('Rekeningmu Sudah\nTerdaftar di Akun Lain',
                        textAlign: TextAlign.center,
                        style: AppTypography.headingMd),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Semantics(
                      button: true,
                      label: 'Tutup informasi tanggungan rekening',
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                        child: Container(
                          width: AppSpacing.xl3,
                          height: AppSpacing.xl3,
                          decoration: const BoxDecoration(
                            color: AppColors.bgLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: AppSpacing.iconXl,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Akun Komerce-mu yang lain masih ada tanggungan saldo minus.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMdRegular
                    .copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.alwaysWhite,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md3),
                      child: Row(children: [
                        Expanded(
                          child: Text('Email',
                              style: AppTypography.bodySmSemiBold),
                        ),
                        Text('Kewajiban Top up',
                            style: AppTypography.bodySmSemiBold),
                      ]),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 176),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.liabilities.length,
                        itemBuilder: (_, index) {
                          final item = widget.liabilities[index];
                          return DecoratedBox(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.grey200),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md3,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(children: [
                                Expanded(
                                  child: Text(item.email,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmRegular
                                          .copyWith(
                                              color: AppColors.errorBase)),
                                ),
                                Text(_rupiah(item.balance),
                                    style: AppTypography.bodySmRegular
                                        .copyWith(color: AppColors.errorBase)),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Bayar tanggungan dahulu untuk lanjut tambah rekening.',
                    style: AppTypography.bodySmRegular),
              ),
              const SizedBox(height: AppSpacing.md),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Alasan Penambahan Rekening*',
                    style: AppTypography.bodySmMedium),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reason,
                maxLines: 3,
                maxLength: 255,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tulis alasanmu minimal 10 karakter',
                  errorText: _hasReasonInput && !_isReasonValid
                      ? 'Alasan minimal 10 karakter'
                      : null,
                  filled: true,
                  fillColor: AppColors.alwaysWhite,
                  contentPadding: const EdgeInsets.all(AppSpacing.md3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
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
