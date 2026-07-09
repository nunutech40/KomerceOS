import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class TabButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final String text;
  final Widget? icon;

  const TabButton({super.key, 
    required this.isActive,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (isActive) return primaryColor;
              return Colors.white;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (isActive) return Colors.white;
              return primaryColor;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              if (!isActive) {
                return const BorderSide(color: borderGray, width: 0.6);
              }
              return BorderSide.none;
            },
          ),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0))),
      child: Row(
        children: [
          Text(
            text,
            style: AppTypography.regular14,
          ),
          if (icon != null) ...[
            const SizedBox(width: 8.0),
            icon! // Include the icon if it's not null
          ]
        ],
      ),
    );
  }
}
