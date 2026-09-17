import 'package:flutter/material.dart';

class BuildRoleBadge extends StatelessWidget {
  final String role;

  const BuildRoleBadge({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (role) {
      case 'Customer Service':
        bg = const Color(0xFFFEEBEC);
        border = const Color(0xFFFFDBDC);
        text = const Color(0xFFE5484D);
        break;
      case 'Live Streamer':
        bg = const Color(0xFFFFEFD6);
        border = const Color(0xFFFFDFB5);
        text = const Color(0xFFF76B15);
        break;
      case 'Admin Marketplace':
        bg = const Color(0xFFE6F4FE);
        border = const Color(0xFFD5EFFF);
        text = const Color(0xFF0090FF);
        break;
      case 'Advertiser':
        bg = const Color(0xFFE6F6EB);
        border = const Color(0xFFD6F1DF);
        text = const Color(0xFF30A46C);
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        border = const Color(0xFFF5F5F5);
        text = const Color(0xFF737373);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
