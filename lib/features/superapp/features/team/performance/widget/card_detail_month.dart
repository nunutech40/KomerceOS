import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/styles.dart' as styles;

class CardDetailMonth extends StatelessWidget {
  final String name;
  final String role;
  final String nameProduct;
  final String leads;
  final String transaksi;
  final String cbt;
  final String cr;
  const CardDetailMonth(
      {required this.name,
      required this.role,
      required this.nameProduct,
      required this.leads,
      required this.transaksi,
      required this.cbt,
      required this.cr,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          // Tambahkan warna latar belakang
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withValues(alpha: 0.7), // Warna bayangan dengan transparansi
              spreadRadius: 1, // Jarak penyebaran bayangan
              blurRadius: 4, // Tingkat blur bayangan
              offset: const Offset(0, 3), // Arah bayangan (x, y)
            ),
          ],
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          widgetHeader(
            name: name,
            role: role,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 0,
            ),
          ),
          widgetContent(
            nameProduct: nameProduct,
            leads: leads,
            transaction: transaksi,
            cbt: cbt,
          ),
        ],
      ),
    );
  }

  Widget widgetContent(
      {String? nameProduct, String? leads, String? transaction, String? cbt}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 14, top: 14, left: 20, right: 20),
      decoration: BoxDecoration(
        // color: f4Gray,
        color: styles.lighPrimaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              cardrow(name: "Leads", value: leads),
              cardrow(name: "Transaksi", value: transaction),
              cardrow(name: "CR", value: "$cr%"),
              cardrow(name: "CBT", value: "$cbt"),
            ],
          )
        ],
      ),
    );
  }

  Widget cardrow({String? name, String? value}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                name ?? "",
                style: styles.AppTypography.regular12FF6262,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            value ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget widgetHeader({
    String? name,
    String? role,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                name ?? "",
                style: styles.AppTypography.semiBold12,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(
                width: 6,
              ),
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                    vertical: 2, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  role ?? "",
                  style: AppTypography.bodySmRegular
                      .copyWith(color: AppColors.primaryBase),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
