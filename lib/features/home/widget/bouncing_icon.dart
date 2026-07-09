import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BouncingIcon extends StatefulWidget {
  final Function? onTap;

  const BouncingIcon({super.key, this.onTap});

  @override
  _BouncingIconState createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -3, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap as void Function()?,
              customBorder:
                  const CircleBorder(), // This is correct for circular border without specifying radius.
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 5.0), // Increased padding around the icon to make the tappable area larger.
                child: SvgPicture.asset(
                  'assets/images/ic-arrow-down.svg',
                  height: 24.0,
                  width: 24.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
