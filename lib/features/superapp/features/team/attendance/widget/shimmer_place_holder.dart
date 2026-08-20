import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholderAbasence extends StatelessWidget {
  const ShimmerPlaceholderAbasence({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 5; i++)
          Container(
            margin: const EdgeInsets.only(left: 12, right: 12),
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
                color: Colors.white),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.5))),
                child: Container(
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
                ),
              ),
            ),
          ),
      ],
    );
  }
}
