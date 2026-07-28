import 'package:flutter/material.dart';

/// Animated shimmer placeholder — primitive building block untuk skeleton loading.
/// Tidak butuh package tambahan, menggunakan AnimationController bawaan Flutter.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_animation.value - 1).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 1).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF2F2F2),
              Color(0xFFE8E8E8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton untuk area chart performa (menggantikan CircularProgressIndicator).
/// Menampilkan 7 batang dengan tinggi bervariasi, mirip bar chart asli.
class HomeChartSkeleton extends StatelessWidget {
  const HomeChartSkeleton({super.key});

  static const List<double> _barHeights = [
    120, 80, 150, 60, 180, 100, 140,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skeleton bars
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barHeights.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerBox(
                    width: double.infinity,
                    height: _barHeights[i],
                    borderRadius: 6,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        // Skeleton X-axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (_) => const ShimmerBox(width: 28, height: 10),
          ),
        ),
      ],
    );
  }
}

/// Skeleton untuk grid menu icon (4 item).
/// Muncul saat profile pertama kali loading dan belum ada cache.
class HomeMenuSkeleton extends StatelessWidget {
  const HomeMenuSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
        children: List.generate(
          4,
          (_) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(width: 48, height: 48, borderRadius: 14),
              SizedBox(height: 6),
              ShimmerBox(width: 40, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
