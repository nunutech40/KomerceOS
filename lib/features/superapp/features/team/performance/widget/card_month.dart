import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

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
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Detail",
                    style: AppTypography.regular12White,
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
        color: f4Gray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            nameProduct ?? "",
            style: AppTypography.interSemiBold14,
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
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: 60,
            decoration: BoxDecoration(
              color: lighPrimaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                name ?? "",
                style: AppTypography.regular12FF6262,
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
                      color: blueLight,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: primaryColor)),
                  child: Text(
                    role ?? "",
                    style: AppTypography.regular12Primary,
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
