import 'package:flutter/material.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_payment.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_product.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_talents.dart';

class DetailList extends StatelessWidget {
  final DetailShoppingDataModel? detailShopping;

  const DetailList({super.key, required this.detailShopping});

  Color getColor(String? condition) {
    switch (condition) {
      case 'requested':
        return const Color(0xFFFBA63C);
      case 'rejected':
        return const Color(0xFFE31A1A);
      case 'approved':
        return const Color(0xFF34A770);
      case 'canceled':
        return const Color(0xFF626262);
      case 'completed':
        return const Color(0xFF08A0F7);
      default:
        return Colors.green;
    }
  }

  Color getFillColor(String? condition) {
    switch (condition) {
      case 'requested':
        return const Color(0xFFFFF2E2);
      case 'rejected':
        return const Color(0xFFFFECEC);
      case 'approved':
        return const Color(0xFFDCF3EB);
      case 'canceled':
        return const Color(0xFFE2E2E2);
      case 'completed':
        return const Color(0xFFDFF3FF);
      default:
        return Colors.white;
    }
  }

  String statusShopping(String? condition) {
    switch (condition) {
      case 'requested':
        return 'Diajukan';
      case 'rejected':
        return 'Ditolak';
      case 'approved':
        return 'Disetujui';
      case 'canceled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return '$condition';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_rincian_shopping,
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 4, left: 10, right: 11, bottom: 4),
                      decoration: ShapeDecoration(
                        color: getFillColor(detailShopping?.status),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1,
                              color: getColor(detailShopping?.status)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            statusShopping(detailShopping?.status),
                            style: TextStyle(
                              color: getColor(detailShopping?.status),
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  child: Text(
                    detailShopping?.transactionNo ?? '',
                    style: const TextStyle(
                      color: Color(0xFF818181),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_talent,
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_skill_role,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                detailShopping?.talents != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: detailShopping!.talents!.length,
                        itemBuilder: (context, index) {
                          return ItemTalents(
                            talent: detailShopping!.talents![index],
                          );
                        },
                      )
                    : Container()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_product_name,
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_price,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF818181),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                detailShopping?.shoppingItems != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: detailShopping!.shoppingItems!.length,
                        itemBuilder: (context, index) {
                          return ItemProduct(
                            shoppingItem: detailShopping!.shoppingItems![index],
                          );
                        },
                      )
                    : Container()
              ],
            ),
          ),
          (detailShopping?.status == 'approved' ||
                  detailShopping?.status == 'completed')
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Text(
                                Strings.label_payment,
                                style: TextStyle(
                                  color: Color(0xFF818181),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      detailShopping?.payments != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: detailShopping!.payments!.length,
                              itemBuilder: (context, index) {
                                return ItemPayment(
                                  pay: detailShopping!.payments![index],
                                );
                              },
                            )
                          : Container()
                    ],
                  ),
                )
              : Container(),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: SizedBox(
                        child: Text(
                          Strings.label_total,
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(
                          detailShopping?.total ?? 0, 0),
                      style: const TextStyle(
                        color: Color(0xFFF95E16),
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    child: Text(
                      Strings.label_note,
                      style: TextStyle(
                        color: Color(0xFF818181),
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFE2E2E2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Text(
                              detailShopping?.notes ?? '-',
                              style: TextStyle(
                                color: detailShopping?.notes == '' ||
                                        detailShopping?.notes == null
                                    ? const Color(0xFFC2C2C2)
                                    : const Color(0xFF333333),
                                fontSize: 14,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 0,
                                letterSpacing: -0.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
