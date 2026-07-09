import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final Widget leadingIcon;
  final Widget trailingIcon;
  final VoidCallback onTap;
  final bool isActive;

  const CustomTile({super.key, 
    required this.title,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.1, color: Colors.black), // bottom line
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  leadingIcon,
                  const SizedBox(
                      width: 8.0), // Add some space between the icon and text
                  Text(
                    title,
                    style: isActive == false
                        ? AppTypography.medium14Grey
                        : AppTypography.medium14,
                  ),
                ],
              ),
              trailingIcon,
            ],
          ),
        ),
      ),
    );
  }
}
