import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/styles.dart';
import '../../../../../../common/time_convert.dart';

// ignore: must_be_immutable
class BodyCardAttendance extends StatefulWidget {
  String? imagesClockIn;
  String? imagesClockOut;
  String? clockIn;
  String? clockOut;

  BodyCardAttendance(
      {super.key,
      this.imagesClockIn,
      this.imagesClockOut,
      this.clockIn,
      this.clockOut});

  @override
  State<BodyCardAttendance> createState() => _BodyCardAttendanceState();
}

class _BodyCardAttendanceState extends State<BodyCardAttendance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              widget.imagesClockIn == ''
                  ? Container(
                      height: MediaQuery.of(context).size.width * 0.2,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/ic_close-circle.png"),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text('Tidak Checkin',
                              style: AppTypography.regular8)
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.width * 0.2,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(5)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.imagesClockIn ?? "",
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: primaryColor)),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
              const SizedBox(
                width: 7,
              ),
              widget.clockIn == ''
                  ? Container()
                  : Column(
                      children: [
                        const Text(
                          "Datang",
                          style: AppTypography.regular12Primary,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(timeConvert(widget.clockIn),
                            style: AppTypography.regular12)
                      ],
                    )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.2,
            width: 20,
            child: const VerticalDivider(
              width: 0.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  widget.imagesClockOut == ''
                      ? Container(
                          height: MediaQuery.of(context).size.width * 0.2,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                              color: lightGray,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/ic_close-circle.png"),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text('Tidak Checkout',
                                  style: AppTypography.regular8)
                            ],
                          ),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.width * 0.2,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                              color: lightGray,
                              borderRadius: BorderRadius.circular(5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.imagesClockOut ?? "",
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    )),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  widget.clockOut == ''
                      ? const Text(
                          "Pulang",
                          style: AppTypography.regular12Primary,
                        )
                      : Column(
                          children: [
                            const Text(
                              "Pulang",
                              style: AppTypography.regular12Primary,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(timeConvert(widget.clockOut),
                                style: AppTypography.regular12)
                          ],
                        )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
