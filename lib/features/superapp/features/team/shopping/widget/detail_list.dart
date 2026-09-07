import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/features/superapp/features/team/listteam/widget/dash_line_team.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_payment.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_product.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/item_talents.dart';

class DetailList extends StatelessWidget {
  final DetailShoppingDataModel? detailShopping;

  const DetailList({super.key, required this.detailShopping});

  Color getBadgeBackgroundColor(String? condition) {
    switch (condition) {
      case 'requested':
        return const Color(0xFFF95E16);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'approved':
      case 'completed':
        return const Color(0xFF22C55E);
      case 'canceled':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color getBadgeTextColor(String? condition) {
    switch (condition) {
      case 'canceled':
        return AppColors.black0A0A;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD 1: Rincian Belanja
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardColorFEFCF8,
              border: Border.all(color: const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgFFF7ED,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFFF95E16),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rincian Belanja',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detailShopping?.transactionNo ?? '',
                            style: const TextStyle(
                              color: gray737373,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getBadgeBackgroundColor(detailShopping?.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusShopping(detailShopping?.status),
                        style: TextStyle(
                          color: getBadgeTextColor(detailShopping?.status),
                          fontSize: 12,
                          fontWeight:
                              getBadgeTextColor(detailShopping?.status) ==
                                      AppColors.black0A0A
                                  ? FontWeight.w700
                                  : FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColorFEF9F2,
                    border: Border.all(color: AppColors.cardBorderFEF0DA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Talent',
                              style: TextStyle(
                                color: gray737373,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Skill Role',
                              style: TextStyle(
                                color: gray737373,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      detailShopping?.talents != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: detailShopping!.talents!.length,
                              itemBuilder: (context, index) {
                                return ItemTalents(
                                  talent: detailShopping!.talents![index],
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // CARD 2: Detail Barang
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF3F4F6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBgFFF7ED,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFFF95E16),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detail Barang',
                        style: TextStyle(
                          color: AppColors.black0A0A,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nama Barang',
                        style: TextStyle(
                          color: gray737373,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Harga',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: gray737373,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                detailShopping?.shoppingItems != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: detailShopping!.shoppingItems!.length,
                        itemBuilder: (context, index) {
                          return ItemProduct(
                            shoppingItem: detailShopping!.shoppingItems![index],
                          );
                        },
                      )
                    : Container(),
                const SizedBox(height: 12),
                const DashedLine(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: AppColors.black0A0A,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(
                          detailShopping?.total ?? 0, 0),
                      style: const TextStyle(
                        color: Color(0xFFF95E16),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Catatan',
                  style: TextStyle(
                    color: gray737373,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (detailShopping?.notes == null ||
                            detailShopping?.notes == '')
                        ? '-'
                        : detailShopping!.notes!,
                    style: TextStyle(
                      color: (detailShopping?.notes == null ||
                              detailShopping?.notes == '')
                          ? gray737373
                          : AppColors.black0A0A,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Payment History (if any)
          (detailShopping?.status == 'approved' ||
                  detailShopping?.status == 'completed')
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Pembayaran',
                        style: TextStyle(
                          color: AppColors.black0A0A,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      detailShopping?.payments != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: detailShopping!.payments!.length,
                              itemBuilder: (context, index) {
                                return ItemPayment(
                                  pay: detailShopping!.payments![index],
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
