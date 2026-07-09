import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetBalance extends StatelessWidget {
  final int type;
  final String buttonText;
  final VoidCallback? onClose;
  final DashboardBalanceDataModel? data;

  const BottomSheetBalance({
    super.key,
    required this.type,
    this.buttonText = "Tutup",
    this.onClose,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 139,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (type == 1) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SvgPicture.asset(
                    'assets/images/ic_info-circle_red.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sebagian saldo kamu masih ditahan sebagai cadangan Saldo Ideal Komship. Top-up saldo untuk lanjut transaksi, ya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'Saldo ideal diterapkan untuk menghindari saldo minus. ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Pelajari lebih lanjut',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse(
                                'https://bantuan.komerce.id/id/article/saldo-ideal-komship-7dn9vp/',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8), bottom: Radius.circular(8)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_message_question.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              'Darimana Saldo Ideal berasal?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF828282),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'Potensi Pendapatan Order Dikirim (${CurrencyFormat.convertToIdr(data?.incomeOrderPotential.toInt() ?? 0,0)}) - Ongkir Retur Ketika Sampai (${CurrencyFormat.convertToIdr(data?.ongkirReturOnFinished.toInt() ?? 0,0)}) - Resiko Ongkir Menjadi Retur (${CurrencyFormat.convertToIdr(data?.ongkirRiskBecomeRetur.toInt() ?? 0,0)}) = Saldo Ideal ',
                              ),
                              TextSpan(
                                text: '(${CurrencyFormat.convertToIdr(data?.idealBalance.toInt() ?? 0,0)})',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (type == 2) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SvgPicture.asset(
                    'assets/images/ic_info-circle_red.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saldo kamu tidak mencukupi karena sedang diproses untuk penarikan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (type == 3) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  SvgPicture.asset(
                    'assets/images/ic_info-circle_red.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saldo kamu belum bisa digunakan karena sedang diproses untuk penarikan dan tertahan sebagai Saldo Ideal Komship. Silakan top-up untuk lanjut transaksi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'Saldo ideal diterapkan untuk menghindari saldo minus. ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: 'Pelajari lebih lanjut',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse(
                                'https://bantuan.komerce.id/id/article/saldo-ideal-komship-7dn9vp/',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8), bottom: Radius.circular(8)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/ic_message_question.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              'Darimana Saldo Ideal berasal?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF828282),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                             TextSpan(
                                text:
                                    'Potensi Pendapatan Order Dikirim (${CurrencyFormat.convertToIdr(data?.incomeOrderPotential.toInt() ?? 0,0)}) - Ongkir Retur Ketika Sampai (${CurrencyFormat.convertToIdr(data?.ongkirReturOnFinished.toInt() ?? 0,0)}) - Resiko Ongkir Menjadi Retur (${CurrencyFormat.convertToIdr(data?.ongkirRiskBecomeRetur.toInt() ?? 0,0)}) = Saldo Ideal ',
                              ),
                              TextSpan(
                                text: '(${CurrencyFormat.convertToIdr(data?.idealBalance.toInt() ?? 0,0)})',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (onClose != null) onClose!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
