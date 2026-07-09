import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:shimmer/shimmer.dart';

class CardShimmerReportPerformance extends StatelessWidget {
  const CardShimmerReportPerformance({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildShimmerItem(context),
    ]);
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
            border: Border.all(width: 0.1),
            color: f4Gray),
        child: Column(children: [
          Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                margin: const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 14,
                            width: 80,
                            color: Colors.grey[300],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 14,
                          width: 80,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: f4Gray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 14,
                  width: 100,
                  color: Colors.grey[300],
                ),
                Row(
                  children: [
                    cardrow(),
                    cardrow(),
                    cardrow(),
                    cardrow(),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 40,
            width: 180,
            color: Colors.grey[300],
          ),
        ]));
  }

  Widget cardrow() {
    return Expanded(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: 60,
            decoration: BoxDecoration(
              color: f4Gray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                height: 14,
                width: 100,
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Container(
            height: 14,
            width: 100,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
