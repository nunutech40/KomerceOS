import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/profile_avatar_custom.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/common/utils/custom_date_format.dart';
import 'package:komtim_partner/core/domain/entities/shopping_list_model.dart';

class ItemShopping extends StatelessWidget {
  final void Function(int) onPressed;
  final ShoppingListDataModel shopping;

  const ItemShopping(
      {super.key, required this.onPressed, required this.shopping});

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'No Name';
    }

    final names = name.trim().split(" ");
    if (names.isEmpty) {
      return 'No Name';
    }

    if (names.length > 1) {
      final firstName = names[0];
      final lastName = names[names.length - 1];
      return "${firstName[0]}${lastName[0]}";
    } else {
      return names[0][0];
    }
  }

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

  String changeFormat(String date) {
    date = date.replaceAll('-', '/');
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final name = shopping.userRequestName ?? 'No Name';
    final imageUrl =
        'https://placehold.jp/80/34A853/ffffff/150x150.png?text=${getInitials(name)}';

    return GestureDetector(
      onTap: () {
        onPressed(shopping.id ?? 0);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ProfileAvatarCustom(
                                  backgroundImage: imageUrl,
                                  w: 32.0,
                                  h: 32.0,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopping.userRequestName ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: getFillColor(shopping.status),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: getColor(shopping.status),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          statusShopping(shopping.status),
                                          style: TextStyle(
                                            color: getColor(shopping.status),
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
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            changeFormat(
                                CustomDateFormat.convertToDateFormatDMY(
                                    shopping.createdAt ?? '')),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF818181),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            CurrencyFormat.convertToIdr(shopping.total ?? 0, 0),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFFF95E16),
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
