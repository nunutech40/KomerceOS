import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/time_convert.dart';

class CardListAllFeed extends StatelessWidget {
  final String images;
  final String title;
  final String date;
  // final String tagType;
  final VoidCallback ontap;

  const CardListAllFeed({
    super.key,
    required this.images,
    required this.title,
    required this.date,
    // required this.tagType,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 100,
                width: 150,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: images,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: primaryColor)),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/default_banner_feed.png",
                    height: 100,
                    width: 236,
                    fit: BoxFit.cover, // Sesuaikan agar gambar memenuhi area
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppTypography.regular14
                          .copyWith(color: blackColors33),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateConvertWithT(date),
                      style: AppTypography.regular10.copyWith(color: darkGray),
                    ),
                  ],
                ),
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                //         color: tagType == 'training' ? primaryColor : purple),
                //   ),
                // ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
