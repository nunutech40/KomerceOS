import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomCircularIndicator extends StatelessWidget {
  const CustomCircularIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color:
            Colors.black.withValues(alpha: 0.5), // This gives a dim background.
        child: AbsorbPointer(
          absorbing: true,
          child: Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/json/loading-superapp.json',
                    width: 80,
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
