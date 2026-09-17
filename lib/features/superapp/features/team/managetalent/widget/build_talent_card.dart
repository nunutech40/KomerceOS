import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/dot_divider.dart';
import 'package:komtim_partner/features/superapp/features/team/managetalent/widget/build_role_badge.dart';

class BuildTalentCard extends StatelessWidget {
  final String talentName;
  final String talentRole;
  final String talentId;
  final String avatarInitials;
  final bool isBorder;
  final double borderWidth;
  final Color borderColor;
  final String talentLead;
  final String workingDuration;
  final bool hasPendingRequest;
  final VoidCallback? onViewRequest;
  final VoidCallback? onApplyChange;

  const BuildTalentCard({
    super.key,
    this.talentName = "Anisa Rahmawati",
    this.talentRole = "Advertiser",
    this.talentId = "123432DSD",
    this.avatarInitials = "AB",
    this.isBorder = false,
    this.borderWidth = 1.0,
    this.borderColor = const Color(0xFFF0F0F0),
    this.talentLead = "Budi",
    this.workingDuration = "1 tahun 2 bulan",
    this.hasPendingRequest = false,
    this.onViewRequest,
    this.onApplyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isBorder
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              avatarInitials,
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: hasPendingRequest ? 100.0 : 0.0,
                                ),
                                child: Text(
                                  talentName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BuildRoleBadge(role: talentRole),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF9E9E9E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    talentId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF737373),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const DotDivider(
                      color: Color(0xFFE2E2E2),
                      height: 1.0,
                      width: 4.0,
                      gap: 2.0,
                      lineHeight: 6.0,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Talent Lead",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  talentLead,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: const Color(0xFFE2E2E2),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Durasi Kerja",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF828282),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  workingDuration,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: hasPendingRequest
                    ? OutlinedButton.icon(
                        onPressed: onViewRequest,
                        icon: SvgPicture.asset(
                            'assets/images/superapp/team/ic_eyes_red.svg'),
                        label: const Text(
                          "Lihat Request",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: primaryColor, width: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFFFFF4ED),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: onApplyChange,
                        icon: SvgPicture.asset(
                            'assets/images/superapp/team/ic_edit.svg'),
                        label: const Text(
                          "Ajukan Perubahan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (hasPendingRequest)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF95E16),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                "Request Diajukan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
