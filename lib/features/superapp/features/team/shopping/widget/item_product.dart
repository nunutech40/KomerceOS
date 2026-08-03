import 'package:flutter/material.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/data/models/detail_shopping_response.dart';

class ItemProduct extends StatelessWidget {
  final ShoppingItem? shoppingItem;

  const ItemProduct({super.key,  this.shoppingItem});
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
                shoppingItem?.itemName ?? '',
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
                CurrencyFormat.convertToIdr(shoppingItem?.itemTotal ?? 0, 0),
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
