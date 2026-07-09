// shimmer_loaders.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Displays a shimmer effect list view placeholder.
class ShimmerPlaceholderListView extends StatelessWidget {
  final int itemCount;
  
  const ShimmerPlaceholderListView({Key? key, this.itemCount = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildShimmerListItem(context),
    );
  }

  Widget _buildShimmerListItem(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              color: Colors.white,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10.0,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 10.0,
                    color: Colors.white,
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
