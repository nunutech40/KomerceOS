import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholderInvoice extends StatelessWidget {
  const ShimmerPlaceholderInvoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            // Representing Date and Payment Status
            paddedShimmerItem(shimmerRowItem()),
          ],
        ),
      ),
    );
  }

  Widget shimmerRowItem({bool withLongerLeft = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        shimmerContainer(width: 60.0, height: 14.0),
      ],
    );
  }

  Widget shimmerContainer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
    );
  }

  Widget paddedShimmerItem(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: child,
    );
  }
}
