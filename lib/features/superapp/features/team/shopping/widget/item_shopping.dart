import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
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

  Color getBadgeBackgroundColor(String? condition) {
    switch (condition) {
      case 'requested': // Diajukan
        return const Color(0xFFF95E16);
      case 'rejected': // Ditolak
        return const Color(0xFFDC2626);
      case 'approved':
      case 'completed': // Selesai
        return const Color(0xFF22C55E);
      case 'canceled': // Dibatalkan
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      final List<String> months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
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
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                getInitials(name).toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.black0A0A,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getBadgeBackgroundColor(shopping.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusShopping(shopping.status),
                          style: TextStyle(
                            color: getBadgeTextColor(shopping.status),
                            fontSize: 12,
                            fontWeight: getBadgeTextColor(shopping.status) ==
                                    AppColors.black0A0A
                                ? FontWeight.w700
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(shopping.createdAt),
                        style: const TextStyle(
                          color: gray737373,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        CurrencyFormat.convertToIdr(shopping.total ?? 0, 0),
                        style: const TextStyle(
                          color: gray737373,
                          fontSize: 12,
                        ),
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
