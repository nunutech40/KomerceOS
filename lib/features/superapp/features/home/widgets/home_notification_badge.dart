import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/app_typography.dart';
import 'package:komtim_partner/features/superapp/features/notification/bloc/notification_info_bloc.dart';
import 'package:komtim_partner/features/superapp/features/notification/view/notification_page.dart';

/// Badge notifikasi yang berdiri sendiri dengan [BlocBuilder]-nya sendiri.
///
/// Dipisah ke widget terpisah agar ketika [NotificationInfoBloc] rebuild,
/// hanya badge ini yang rebuild — tidak cascade ke [DsHomeHeader] maupun
/// section balance/profile di bawahnya.
class HomeNotificationBadge extends StatelessWidget {
  const HomeNotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationInfoBloc, NotificationInfoState>(
      builder: (context, notifState) {
        int notifCount = 0;
        bool notifHasError = false;
        if (notifState is NotificationInfoLoaded) {
          notifCount = notifState.data.unreadCount;
        } else if (notifState is NotificationInfoError) {
          notifHasError = true;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationPage(),
              ),
            ).then((_) {
              if (context.mounted) {
                context
                    .read<NotificationInfoBloc>()
                    .add(const FetchNotificationInfoEvent());
              }
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/superapp/home/ic_notification.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              // Badge error: '!' oranye jika gagal fetch notifikasi
              if (notifHasError)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '!',
                        style: AppTypography.headingSm
                            .copyWith(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              // Badge merah: tampilkan count jika ada notif belum dibaca
              else if (notifCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFD7EAF6), width: 1),
                      color: AppColors.primaryBase,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        notifCount > 99 ? '99+' : notifCount.toString(),
                        style: AppTypography.headingSm
                            .copyWith(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
