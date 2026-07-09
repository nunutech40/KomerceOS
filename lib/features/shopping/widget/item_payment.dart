import 'package:flutter/material.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/data/models/detail_shopping_response.dart';

class ItemPayment extends StatelessWidget {
  final Payment? pay;

  String _textPay(String payment) {
    if (payment == 'kmpoin') {
      return 'Saldo Kompay';
    } else {
      return 'Kompoin Digunakan';
    }
  }

  String _textNominal(String nominal) {
    if (Payment == 'kmpoin') {
      return CurrencyFormat.convertToIdr(pay?.nominal ?? 0, 0);
    } else {
      return '-${CurrencyFormat.convertWithoutSymbol(pay?.nominal ?? 0, 0)} Poin';
    }
  }

  const ItemPayment({super.key, this.pay});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              child: Text(
                _textPay(pay?.paymentName ?? ''),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              child: Text(
                _textNominal(pay?.paymentName ?? ''),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
