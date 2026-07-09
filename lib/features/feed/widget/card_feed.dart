import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
        width: 236,
        margin: const EdgeInsets.all(8),
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
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar dengan teks di pojok kanan atas
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 100,
                      width: 236,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: images,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: primaryColor)),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/images/default_banner_feed.png",
                          height: 100,
                          width: 236,
                          fit: BoxFit
                              .cover, // Sesuaikan agar gambar memenuhi area
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
                      : Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTypography.regular14
                          .copyWith(color: blackColors33),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateConvertWithT(date),
                      style: AppTypography.regular10.copyWith(color: darkGray),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 8, vertical: 3),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(25),
                    //     color: tagType == 'training'
                    //         ? tagBackgorundPrimaryColor
                    //         : lightPurple,
                    //   ),
                    //   child: Text(
                    //     tagType == 'training' ? "Training" : "Assessment",
                    //     overflow: TextOverflow.ellipsis,
                    //     maxLines: 1,
                    //     style: AppTypography.regular10.copyWith(
                    //         color:
                    //             tagType == 'training' ? primaryColor : purple),
                    //   ),
                    // ),

                    nametalent.isEmpty
                        ? Text(
                            "",
                            style: AppTypography.regular10
                                .copyWith(color: darkGray),
                          )
                        : Text(
                            nametalent.length > 1
                                ? "${nametalent.first.name} dan ${nametalent.length - 1} lainnya"
                                : "${nametalent.first.name}",
                            style: AppTypography.regular10
                                .copyWith(color: darkGray),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
