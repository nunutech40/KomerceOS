import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholderInvoiceList extends StatelessWidget {
  const ShimmerPlaceholderInvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(6, (index) => _buildShimmerItem()),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24.0,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 14,
                  width: 120,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 14,
                  width: 100,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 20,
                width: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 14,
                width: 60,
                color: Colors.grey[300],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
