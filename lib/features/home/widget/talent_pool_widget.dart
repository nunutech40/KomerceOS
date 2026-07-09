import 'package:flutter/material.dart';
import 'package:komtim_partner/common/styles.dart';

class TalentPoolWidget extends StatelessWidget {
  final String name;
  final String role;
  final String profileImageUrl;
  final int heartCount;
  final String partnersText;
  final VoidCallback? onViewDetails;
  final double width;
  final VoidCallback? onTap;

  const TalentPoolWidget({
    Key? key,
    required this.name,
    this.role = "Customer Service",
    required this.profileImageUrl,
    required this.heartCount,
    this.partnersText = "partner lain",
    this.onViewDetails,
    this.width = 230,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withValues(alpha: 0.7), // Warna bayangan dengan transparansi
              spreadRadius: 1, // Jarak penyebaran bayangan
              blurRadius: 4, // Tingkat blur bayangan
              offset: const Offset(0, 3), // Arah bayangan (x, y)
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  profileImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: blackColors33,
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              name,
              style: AppTypography.regular14
                  .copyWith(color: blackColors33, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Role
            Text(
              role,
              style: AppTypography.regular12
                  .copyWith(color: primaryColor, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Heart Count Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTypography.regular12.copyWith(
                          color: blackColors, fontWeight: FontWeight.normal),
                      children: [
                        const TextSpan(text: "Ditandai oleh "),
                        TextSpan(
                          text: heartCount.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: " $partnersText"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // View Details Button
            InkWell(
              onTap: onTap,
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: primaryColor,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    "Lihat Detail",
                    style: AppTypography.regular14.copyWith(
                        color: primaryColor, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
