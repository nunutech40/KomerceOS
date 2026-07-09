import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholderAttendance extends StatelessWidget {
  int index;

  ShimmerPlaceholderAttendance({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (index) => _buildShimmerItem(context, index)),
    );
  }

  Widget _buildShimmerItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(left: 4, right: 4, top: index == 0 ? 0 : 16),
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
        child: Column(children: [
          Container(
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
          Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.2,
                        width: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Column(
                        children: [
                          Container(
                            height: 14,
                            width: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 14,
                            width: 40,
                            color: Colors.grey[300],
                          ),
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
                      Container(
                        height: MediaQuery.of(context).size.width * 0.2,
                        width: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Column(
                        children: [
                          Container(
                            height: 14,
                            width: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 14,
                            width: 40,
                            color: Colors.grey[300],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ))
        ]),
      ),
    );
  }
}
