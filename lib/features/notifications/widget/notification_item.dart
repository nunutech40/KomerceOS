
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/utils/custom_date_format.dart';
import 'package:komtim_partner/core/domain/entities/notifications_model.dart';
import '../../../common/styles.dart';

class NotificationItem extends StatelessWidget {
  final NotificationsDataModel? dataModel;

  const NotificationItem({Key? key, this.dataModel}) : super(key: key);

  String timeAgo(String dateStr) {
    final DateTime createdAt = DateTime.parse(dateStr);
    final DateTime currentDate = DateTime.now();
    final Duration difference = currentDate.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit${difference.inMinutes == 1 ? '' : 's'} lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam${difference.inHours == 1 ? '' : ''} lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari${difference.inDays == 1 ? '' : ''} lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu${(difference.inDays / 7).floor() == 1 ? '' : ''} lalu';
    } else {
      // You can format this further as per your requirements
      return CustomDateFormat.convertToDateFormat(dateStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: dataModel?.isRead == 1 ? Colors.white : creameColor),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    dataModel?.notificationType == 18
                        ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: dataModel?.attachmentImageUrl ?? "",
                            imageBuilder: (context, imageProvider) => Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                )),
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: primaryColor)),
                            ),
                            errorWidget: (context, url, error) => Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                        "assets/images/default_banner_feed.png",
                                      ),
                                      fit: BoxFit.cover),
                                )),
                          )
                        : SvgPicture.asset(
                            'assets/images/ic-invoice-list.svg',
                            width: 40,
                            height: 40,
                          ),
                    const SizedBox(
                      width: 12.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dataModel?.title ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight:
                                        FontWeight.w500, // medium weight
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                timeAgo(dataModel?.createdAt ?? ''),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight:
                                      FontWeight.normal, // medium weight
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          dataModel?.notificationType == 18
                              ? Text(
                                  dataModel?.message ?? '',
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          FontWeight.normal, // medium weight
                                      fontSize: 12,
                                      color: darkGray),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  dataModel?.invoiceCode ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight:
                                        FontWeight.normal, // medium weight
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          dataModel?.notificationType == 18
                              ? Container()
                              : Text(
                                  dataModel?.message ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          FontWeight.normal, // medium weight
                                      fontSize: 12,
                                      color: darkGray),
                                  overflow: TextOverflow.ellipsis,
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
      ],
    );
  }
}
