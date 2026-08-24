import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class CardWeek extends StatelessWidget {
  final String name;
  final String role;
  final String date;
  final String nameProduct;
  final String leads;
  final String transaksi;
  final String cr;
  final String cbt;
  const CardWeek(
      {required this.name,
      required this.role,
      this.date = '',
      required this.nameProduct,
      required this.leads,
      required this.transaksi,
      required this.cr,
      required this.cbt,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md3),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 9,
              spreadRadius: 0.3,
              offset: Offset.zero,
            ),
          ],
          borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        children: [
          widgetHeader(
            name: name,
            role: role,
            date: date,
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
            cr: cr,
            cbt: cbt,
          ),
        ],
      ),
    );
  }

  Widget widgetContent(
      {String? nameProduct,
      String? leads,
      String? transaction,
      String? cr,
      String? cbt}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 14, top: 14, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            nameProduct ?? "",
            style: AppTypography.numericMdSemiBold,
          ),
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
            margin: const EdgeInsets.only(top: AppSpacing.md3),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.alwaysWhite,
              borderRadius: BorderRadius.circular(AppRadius.md3),
            ),
            child: Center(
              child: Text(
                name ?? "",
                style: AppTypography.bodySmRegular
                    .copyWith(color: AppColors.grey700),
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
    String? date,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                name ?? "",
                style: AppTypography.bodySmSemiBold,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),
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
        )),
      ],
    );
  }
}
