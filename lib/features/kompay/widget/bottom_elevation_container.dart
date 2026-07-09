import 'dart:math' as math;

// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class BottomElevationContainer extends StatelessWidget {
  final double elevationHeight;
  final Widget content;
  bool? status;
  VoidCallback onTap;

  BottomElevationContainer(
      {super.key,
      required this.elevationHeight,
      required this.content,
      required this.status,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: math.max(0, MediaQuery.of(context).viewInsets.bottom),
            left: 0,
            right: 0,
            height: elevationHeight,
            child: status == false
                ? Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // Change the background color as needed
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                              0, 0), // Customize the shadow properties
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        color: Colors
                            .white, // Change the background color as needed
                        child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 45,
                            decoration: BoxDecoration(
                                color: onlyGray,
                                borderRadius: BorderRadius.circular(10)),
                            child: content),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.white, // Change the background color as needed
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(
                              0, 0), // Customize the shadow properties
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        color: Colors
                            .white, // Change the background color as needed
                        child: InkWell(
                          onTap: onTap,
                          child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: 45,
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: content),
                        ),
                      ),
                    ),
                  )),
      ],
    );
  }
}
