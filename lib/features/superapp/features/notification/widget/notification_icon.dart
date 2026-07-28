import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const NotificationIcon({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
