import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';

class CardMonth extends StatelessWidget {
  final String nameProduct;
  final String leads;
  final String transaksi;
  final String cr;
  final VoidCallback ontap;
  const CardMonth({
    required this.nameProduct,
    required this.leads,
    required this.transaksi,
    required this.cr,
    required this.ontap,
    super.key,
  });

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
          widgetContent(
            nameProduct: nameProduct,
            leads: leads,
            transaction: transaksi,
            cr: cr,
          ),
          InkWell(
            onTap: ontap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9.5),
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryBase,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Detail",
                    style: AppTypography.bodySmRegular
                        .copyWith(color: AppColors.alwaysWhite),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset("assets/images/ic_arrow_right.svg",
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 20,
                      height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget widgetContent({
    String? nameProduct,
    String? leads,
    String? transaction,
    String? cr,
  }) {
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
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name ?? "",
                    style: AppTypography.interRegular12,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 2, horizontal: 14),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                      border: Border.all(color: AppColors.primaryBase)),
                  child: Text(
                    role ?? "",
                    style: AppTypography.bodySmRegular
                        .copyWith(color: AppColors.primaryBase),
                  ),
                ),
              ],
            )),
        Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  date ?? "",
                  style: AppTypography.interRegular12,
                ),
              ],
            ))
      ],
    );
  }
}
