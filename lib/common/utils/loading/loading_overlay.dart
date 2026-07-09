// loading_overlay.dart
import 'package:flutter/material.dart';

import '../../global/pages/custom_circular_indicator.dart';

/// Displays a loading overlay over the entire screen.
///
/// [overlayColor] allows changing the overlay's background color.
/// [loadingIndicator] is a widget that will be centered on the overlay. By default, it uses `CustomCircularIndicator`.
class LoadingOverlay extends StatelessWidget {
  final Color overlayColor;
  final Widget loadingIndicator;

  const LoadingOverlay({
    Key? key,
    this.overlayColor = Colors.black38,
    this.loadingIndicator = const CustomCircularIndicator(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: overlayColor,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: loadingIndicator,
          ),
        ),
      ),
    );
  }
}
