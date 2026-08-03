import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';

class CardToday extends StatelessWidget {
  final String name;
  final String role;
  final String date;
  final String nameProduct;
  final String leads;
  final String transaksi;
  final String cr;
  final String cbt;
  final String keterangan;
  final bool status;
  final VoidCallback ontap;
  final VoidCallback ontap2;
  const CardToday(
      {required this.name,
      required this.role,
      required this.date,
      required this.nameProduct,
      required this.leads,
      required this.transaksi,
      required this.cr,
      required this.cbt,
      required this.keterangan,
      required this.status,
      required this.ontap,
      required this.ontap2,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            // Tambahkan warna latar belakang
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(
                    alpha: 0.7), // Warna bayangan dengan transparansi
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
            widgetNote(
              status: status,
              note: keterangan,
            )
          ],
        ),
      ),
    );
  }

  Widget widgetNote({bool? status, String? note}) {
    return status == false
        ? InkWell(
            onTap: ontap2,
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
                    "Selengkapnya",
                    style: AppTypography.regular12White,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset("assets/images/ic_arrow_bottom.svg",
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 20,
                      height: 20),
                ],
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Keterangan",
                  style: AppTypography.interRegular12,
                ),
                Container(
                  height: 92,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundContainerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note ?? "",
                    style: AppTypography.regular12FF6262,
                  ),
                ),
                InkWell(
                  onTap: ontap2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9.5),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Lebih Sedikit",
                          style: AppTypography.regular12Primary,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        SvgPicture.asset("assets/images/ic_arrow_up.svg",
                            colorFilter: const ColorFilter.mode(
                                primaryColor, BlendMode.srcIn),
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
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              name ?? "",
              style: AppTypography.semiBold12,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              date ?? "",
              style: AppTypography.interRegular12,
            ),
          ],
        )
      ],
    );
  }
}
