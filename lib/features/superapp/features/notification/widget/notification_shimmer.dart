import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_spacing.dart';

// -----------------------------------------------------------------------------
// NotificationShimmer
//
// Skeleton loading placeholder untuk halaman Notifikasi.
// Terdiri dari 2 komponen:
//   - [NotificationItemShimmer] : satu baris notifikasi (icon + teks)
//   - [NotificationListShimmer] : daftar shimmer lengkap dengan group header
//   - [NotificationLoadMoreShimmer] : shimmer kecil di bawah list (lazy load)
// -----------------------------------------------------------------------------

/// Box animasi shimmer generik. Tidak perlu package eksternal.
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
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
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF8F8F8),
                Color(0xFFEEEEEE),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer untuk satu item notifikasi (icon bulat + 3 baris teks).
class NotificationItemShimmer extends StatelessWidget {
  const NotificationItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.alwaysWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            const _ShimmerBox(width: 40, height: 40, borderRadius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris judul
                  const _ShimmerBox(
                    width: double.infinity,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  // Baris deskripsi panjang
                  const _ShimmerBox(
                    width: double.infinity,
                    height: 12,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 6),
                  // Baris deskripsi pendek
                  _ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: 12,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 10),
                  // Baris waktu (pojok kanan)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: _ShimmerBox(
                      width: 80,
                      height: 10,
                      borderRadius: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer untuk satu group notifikasi (header tanggal + beberapa item).
class _NotificationGroupShimmer extends StatelessWidget {
  final int itemCount;

  const _NotificationGroupShimmer({this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header tanggal (misal "Hari ini", "Kemarin")
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: _ShimmerBox(width: 80, height: 14, borderRadius: 4),
        ),
        ...List.generate(itemCount, (_) => const NotificationItemShimmer()),
      ],
    );
  }
}

/// Shimmer lengkap untuk first-load (menggantikan CircularProgressIndicator).
/// Tampilkan beberapa group seolah-olah sudah ada data.
class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _NotificationGroupShimmer(itemCount: 3),
        _NotificationGroupShimmer(itemCount: 2),
        _NotificationGroupShimmer(itemCount: 2),
      ],
    );
  }
}

/// Shimmer kecil di bagian bawah list saat lazy load (load more).
/// Menggantikan CircularProgressIndicator di footer list.
class NotificationLoadMoreShimmer extends StatelessWidget {
  const NotificationLoadMoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          NotificationItemShimmer(),
          NotificationItemShimmer(),
        ],
      ),
    );
  }
}
