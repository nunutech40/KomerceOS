import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/widgets/custom_toast.dart';
import 'package:komtim_partner/features/update/widget/update_complete.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../myapp/view/my_app_page.dart';
import '../widget/setting_menu_item.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Left-aligned Page Title
              Text(
                'Pengaturan',
                style: AppTypography.headingLg.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),

              // Centered Profile Section
              Center(
                child: Column(
                  children: [
                    // Profile Photo Container
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFF0E6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(
                          "https://img.magnific.com/vektor-gratis/ilustrasi-ikon-vektor-kartun-anak-laki-laki-keren-lucu-berpose-dabbing-konsep-ikon-mode-orang-terpencil_138676-5680.jpg?semt=ais_hybrid&w=740&q=80",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: AppColors.primaryBase,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Profile Name
                    Text(
                      'John Doe Assegaf',
                      style: AppTypography.headingXs.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Profile Email
                    Text(
                      'johndoe@gmail.com',
                      style: AppTypography.bodyMdRegular.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Group 1: Informasi Akun, Aplikasiku, Tutorial & FAQ
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Column(
                    children: [
                      SettingMenuItem(
                        leadingBackgroundColor: AppColors.bgLight,
                        leadingIcon: Image.asset(
                          'assets/images/superapp/home/navbar/ic_setting_inactive.png',
                        ),
                        title: 'Informasi Akun',
                        titleColor: AppColors.alwaysBlack,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        onTap: () {},
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                      ),
                      SettingMenuItem(
                        leadingBackgroundColor: AppColors.bgLight,
                        leadingIcon: Image.asset(
                          'assets/images/superapp/ic_application.png',
                        ),
                        title: 'Aplikasiku',
                        titleColor: AppColors.alwaysBlack,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyAppPage(),
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                      ),
                      SettingMenuItem(
                        leadingBackgroundColor: AppColors.bgLight,
                        leadingIcon: Image.asset(
                          'assets/images/superapp/ic_faq.png',
                        ),
                        title: 'Tutorial & FAQ',
                        titleColor: AppColors.alwaysBlack,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        onTap: () async {
                          final uri =
                              Uri.parse('https://bantuan.komerce.id/id/');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Group 2: Check for Update
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: SettingMenuItem(
                    leadingBackgroundColor: AppColors.bgLight,
                    leadingIcon: Image.asset(
                      'assets/images/superapp/ic_check_update.png',
                    ),
                    title: 'Check for Update',
                    titleColor: AppColors.alwaysBlack,
                    trailingText: 'V 1.2.0',
                    borderRadius: BorderRadius.circular(99),
                    onTap: () async {
                      if (Platform.isIOS) {
                        final Uri uri = Uri.parse(
                            "https://apps.apple.com/id/app/komtim/id6473518650");
                        if (await canLaunchUrl(uri)) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      } else {
                        InAppUpdate.checkForUpdate().then((updateInfo) {
                          if (updateInfo.updateAvailability ==
                              UpdateAvailability.updateAvailable) {
                            if (updateInfo.immediateUpdateAllowed) {
                              InAppUpdate.performImmediateUpdate()
                                  .then((appUpdateResult) {
                                if (appUpdateResult ==
                                    AppUpdateResult.success) {
                                  if (!context.mounted) return;
                                  bottomSheetUpdateSuccess(context);
                                }
                              });
                            }
                          } else {
                            if (!context.mounted) return;
                            showToast(context, 'Aplikasi sudah versi terbaru');
                          }
                        }).catchError((e) {
                          if (!context.mounted) return;
                          showToast(context, 'Gagal memeriksa update');
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Group 3: Keluar (Logout)
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.alwaysWhite,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: SettingMenuItem(
                    leadingIcon: Image.asset(
                      'assets/images/superapp/ic_logout.png',
                    ),
                    leadingBackgroundColor: const Color(0xFFFEEBEC),
                    title: 'Keluar',
                    titleColor: AppColors.errorBase,
                    borderRadius: BorderRadius.circular(99),
                    onTap: () {
                      DsBottomSheet.show(
                        context: context,
                        title: 'Keluar Akun?',
                        description:
                            'Kamu akan keluar dari akun saat ini dan dapat masuk kembali kapan saja?',
                        image: Image.asset(
                          'assets/images/superapp/setting/failed_img.png',
                          width: 240,
                          height: 240,
                        ),
                        primaryButtonText: 'Keluar',
                        onPrimaryPressed: () {
                          // Dummy logout endpoint action
                          Navigator.of(context).pop();
                          showToast(context,
                              "Proses logout sedang dalam pengembangan.");
                        },
                        secondaryButtonText: 'Batal',
                        onSecondaryPressed: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
