import 'package:flutter/material.dart';

import '../../../common/styles.dart';

class ListSectionTalent extends StatelessWidget {
  const ListSectionTalent({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 8.0;
    const double itemHeight =
        24.0 + verticalPadding; // Total height of each item, including padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(title, style: AppTypography.semiBold14),
        ),
        SizedBox(
          height: items.length *
              itemHeight, // Calculate the total height of the ListView
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemExtent: itemHeight, // Set the height of each item explicitly
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: verticalPadding),
                  child: Text(
                    items[index],
                    style: AppTypography.regular12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
