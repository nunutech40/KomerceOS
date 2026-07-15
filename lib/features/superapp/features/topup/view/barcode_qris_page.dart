import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_result_page.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BarcodeQrisPage extends StatefulWidget {
  final int amount;

  const BarcodeQrisPage({
    super.key,
    required this.amount,
  });

  @override
  State<BarcodeQrisPage> createState() => _BarcodeQrisPageState();
}

class _BarcodeQrisPageState extends State<BarcodeQrisPage> {
  bool _showPaymentError = false;
  String _getExpiryText() {
    final expiryDate = DateTime.now().add(const Duration(days: 1));
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${expiryDate.day} ${months[expiryDate.month - 1]} ${expiryDate.year}';
  }

  Widget _buildStepCard(String number, String boldText, String normalText) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.alwaysWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$number.',
              style: AppTypography.bodyMdRegular.copyWith(
                color: AppColors.grey800,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.grey800,
                ),
                children: [
                  if (boldText.isNotEmpty)
                    TextSpan(
                      text: boldText,
                      style: AppTypography.bodyMdSemiBold.copyWith(
                        color: AppColors.grey800,
                      ),
                    ),
                  TextSpan(text: normalText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmBottomSheet(BuildContext context) {
    DsBottomSheet.show(
      context: context,
      title: 'Batalkan Pembayaran',
      image: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Image.asset(
          'assets/images/superapp/ilustration_cancel.png'
        )
      ),
      description: 'Kamu yakin ingin membatalkan pembayaran\nTop Up saldo Kompaymu?',
      primaryButtonText: 'Lanjut Bayar',
      onPrimaryPressed: () {
        Navigator.pop(context);
      },
      secondaryButtonText: 'Batalkan Pembayaran',
      secondaryButtonColor: AppColors.errorBase,
      onSecondaryPressed: () {
        Navigator.pop(context);
        Navigator.maybePop(context);
      },
    );
  }

  void _showInstructions(BuildContext context) {
    DsBottomSheet.show(
      context: context,
      title: 'Trik Scan QRIS di 1 Device',
      description: '',
      primaryButtonText: 'Kembali',
      onPrimaryPressed: () => Navigator.pop(context),
      image: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepCard('1', 'Screenshot QR Kode ', 'yang ingin kamu bayar'),
          _buildStepCard('2', 'Buka E-wallet / Mbanking ',
              'bank kamu yang sudah memiliki fitur Scan QRIS'),
          _buildStepCard('3', 'Klik icon gambar ',
              'untuk masuk ke galeri kamu dan pilih hasil screenshot QR Kode di step 1'),
          _buildStepCard('4', '',
              'Rincian pembayaran kamu akan muncul dan mohon periksa kembali apakah sudah sesuai'),
          _buildStepCard(
              '5', '', 'Jika sudah sesuai lanjutkan pembayaran sampai selesai'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountText = CurrencyFormat.convertToIdrWithSpasi(widget.amount, 0);

    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Scan QRIS',
                style: AppTypography.headingMd.copyWith(
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Silahkan scan QRIS untuk melanjutkan pembayaran',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMdRegular.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // QRIS Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.alwaysWhite,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.grey200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Card Header: QRIS Logo & Expiration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/qris.svg',
                              height: 18,
                              placeholderBuilder: (_) => const Text(
                                'QRIS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QR Code Standar',
                                  style: AppTypography.bodyMdMedium.copyWith(
                                    color: AppColors.alwaysBlack,
                                  ),
                                ),
                                Text(
                                  'Pembayaran Nasional',
                                  style: AppTypography.bodyMdMedium.copyWith(
                                    color: AppColors.alwaysBlack,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Bayar Sebelum',
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.alwaysBlack,
                              ),
                            ),
                            Text(
                              _getExpiryText(),
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.errorBase,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Merchant Name
                    Text(
                      'Komerce.id',
                      style: AppTypography.headingXs.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // QR Code
                    Center(
                      child: QrImageView(
                        data:
                            'https://komerce.id/pay/qris?amount=${widget.amount}',
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        errorStateBuilder: (cxt, err) {
                          return const Center(
                            child: Text(
                              'Gagal membuat QR Code',
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Amount
                    Text(
                      amountText,
                      style: AppTypography.headingSm.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Scan instructions trigger
                    InkWell(
                      onTap: () => _showInstructions(context),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Scan dari ponsel ini',
                              style: AppTypography.bodyMdSemiBold.copyWith(
                                color: AppColors.primaryBase,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 16,
                              color: AppColors.primaryBase,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Cancel Payment Button
              TextButton(
                onPressed: () => _showConfirmBottomSheet(context),
                child: Text(
                  'Batalkan Pembayaran',
                  style: AppTypography.bodyMdSemiBold.copyWith(
                    color: AppColors.primaryBase,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DsButton(
                text: 'Sudah Bayar',
                onPressed: () {
                  setState(() => _showPaymentError = true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DsAppResultPage(
                        illustration: Image.asset(
                          'assets/images/superapp/ilustration_cancel.png',
                         
                        ),
                        title: 'Top Up Berhasil',
                        description: 'Top up saldo berhasil, silahkan refresh halaman beranda kamu, ya',
                        action: DsButton(
                          text: 'Kembali',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_showPaymentError) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.errorBase,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pembayaran belum berhasil',
                      style: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.errorBase,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
