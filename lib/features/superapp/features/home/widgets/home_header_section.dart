import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/utils/currency_format.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/balance_summary_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/bloc/revenue_performance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/ds_home_header.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_notification_badge.dart';
import 'package:komtim_partner/features/superapp/features/home/widgets/home_verification_bottom_sheet.dart';

/// Header Home — foto profil, nama, savings, badge notifikasi.
///
/// Internally menggunakan [BlocConsumer] untuk:
/// - listen: trigger fetch balance/revenue saat [isKomshipVerified] berubah
///           dan tampilkan BottomSheet verifikasi produk.
/// - build : rebuild DsHomeHeader hanya saat data yang ditampilkan berubah.
class HomeHeaderSection extends StatefulWidget {
  const HomeHeaderSection({super.key});

  @override
  State<HomeHeaderSection> createState() => _HomeHeaderSectionState();
}

class _HomeHeaderSectionState extends State<HomeHeaderSection> {
  bool _hasShownVerificationBottomSheet = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SuperappProfileBloc, SuperappProfileState>(
      listener: (context, profileState) {
        // Tampilkan BottomSheet Verifikasi Produk (hanya sekali)
        if (!_hasShownVerificationBottomSheet &&
            profileState.unverifiedProducts.isNotEmpty) {
          _hasShownVerificationBottomSheet = true;
          // Simpan context sebelum async gap
          final capturedContext = context;
          Future.microtask(() {
            if (!capturedContext.mounted) return;
            HomeVerificationBottomSheet.show(context: capturedContext);
          });
        }

        // Fetch balance summary & revenue saat komship verified berubah
        if (profileState.isKomshipVerified) {
          if (profileState.displayProfile?.id != null) {
            context.read<BalanceSummaryBloc>().add(FetchBalanceSummaryEvent(
                profileState.displayProfile!.id.toString()));
          }
          context
              .read<RevenuePerformanceBloc>()
              .add(const FetchRevenuePerformanceEvent());
        }
      },
      listenWhen: (prev, curr) =>
          prev.isKomshipVerified != curr.isKomshipVerified ||
          prev.unverifiedProducts.length != curr.unverifiedProducts.length,
      buildWhen: (prev, curr) =>
          prev.displayProfile?.photoProfileUrl !=
              curr.displayProfile?.photoProfileUrl ||
          prev.displayProfile?.fullName != curr.displayProfile?.fullName ||
          prev.displayProfile?.isKomship != curr.displayProfile?.isKomship,
      builder: (context, profileState) {
        final isKomship = profileState.isKomshipVerified;

        // BlocSelector: rebuild DsHomeHeader HANYA jika savings benar-benar berubah
        return BlocSelector<BalanceSummaryBloc, BalanceSummaryState, String?>(
          selector: (state) {
            String formatNominal(num value) {
              if (value == 0) return 'Rp 0';
              if (value % 1 == 0) {
                return CurrencyFormat.convertToIdrNum(value, 0);
              }
              return CurrencyFormat.convertToIdrNum(value, 2);
            }

            if (state is BalanceSummaryLoaded) {
              return formatNominal(state.data.totalEarnCashback ?? 0);
            } else if (state is BalanceSummaryError) {
              return '--';
            }
            return null;
          },
          builder: (context, savings) {
            return DsHomeHeader(
              profileUrl:
                  profileState.displayProfile?.photoProfileUrl ?? '',
              partnerName: profileState.displayProfile?.fullName ?? '',
              type: isKomship ? PartnerType.komship : PartnerType.regular,
              savingsAmount: isKomship ? savings : null,
              notificationWidget: const HomeNotificationBadge(),
            );
          },
        );
      },
    );
  }
}
