import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_image.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/time_convert.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';

class CardFeed extends StatelessWidget {
  final String images;
  final String tagTalent;
  final String title;
  final String date;
  // final String tagType;
  final List<Participant> nametalent;
  final VoidCallback ontap;

  const CardFeed({
    super.key,
    required this.images,
    required this.tagTalent,
    required this.title,
    required this.date,
    // required this.tagType,
    required this.nametalent,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar dengan teks di pojok kanan atas
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: images,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/images/default_banner_feed.png",
                        height: 140,
                        width: double.infinity,
                        fit:
                            BoxFit.cover, // Sesuaikan agar gambar memenuhi area
                      ),
                    ),
                  ),
                ),
                tagTalent == 'partner'
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: blue42,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Keahlian Talentmu Meningkat  🚀",
                            style: AppTypography.regular10.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 12, left: 12, right: 12, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style:
                        AppTypography.regular14.copyWith(color: blackColors33),
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateConvertWithT(date),
                        style:
                            AppTypography.regular10.copyWith(color: darkGray),
                      ),
                      if (nametalent.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DsAppImage(
                              source: "assets/images/team/ic_chart.png",
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              nametalent.length > 1
                                  ? "${nametalent.first.name} dan ${nametalent.length - 1} lainnya"
                                  : "${nametalent.first.name}",
                              style: AppTypography.regular10
                                  .copyWith(color: darkGray),
                            ),
                          ],
                        ),
                      ],
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
