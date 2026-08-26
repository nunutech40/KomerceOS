import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/bloc/superapp_profile/superapp_profile_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/features/superapp/features/team/home/bloc/home_team_cubit.dart';
import 'package:komtim_partner/features/superapp/features/team/home/widget/team_action_required_section.dart';
import 'package:komtim_partner/features/superapp/features/team/home/widget/team_feed_section.dart';
import 'package:komtim_partner/features/superapp/features/team/home/widget/team_menu_section.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';

class HomePageTeam extends StatefulWidget {
  const HomePageTeam({Key? key}) : super(key: key);

  @override
  State<HomePageTeam> createState() => _HomePageTeamState();
}

class _HomePageTeamState extends State<HomePageTeam> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeTeamCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeTeamCubit>();

    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: const DsAppBar(title: 'Team'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryBase,
          onRefresh: cubit.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // --- SECTION 1: Action Required Banner ---
                BlocBuilder<InvoiceListBloc, InvoiceListState>(
                  builder: (context, invoiceState) {
                    return BlocBuilder<ShoppingBloc, ShoppingState>(
                      builder: (context, shoppingState) {
                        final unpaidInvoicesCount =
                            invoiceState.needProcessData?.where((i) {
                                  return i.transactionType == 'invoice' || i.transactionType == null;
                                }).length ??
                                0;

                        final requestedShoppingCount = shoppingState
                            .shoppingList
                            .where((s) => s.status == 'requested')
                            .length;

                        return TeamActionRequiredSection(
                          invoiceCount: unpaidInvoicesCount,
                          shoppingCount: requestedShoppingCount,
                          onInvoiceTap: cubit.navigateToInvoice,
                          onShoppingTap: cubit.navigateToShopping,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // --- SECTION 2: Menu Grid ---
                BlocBuilder<SuperappProfileBloc, SuperappProfileState>(
                  builder: (context, profileState) {
                    final accountStatus =
                        profileState.displayProfile?.accountStatus;
                    return BlocBuilder<InvoiceListBloc, InvoiceListState>(
                      builder: (context, invoiceState) {
                        return BlocBuilder<ShoppingBloc, ShoppingState>(
                          builder: (context, shoppingState) {
                            final unpaidInvoicesCount =
                                invoiceState.needProcessData?.where((i) {
                                      return i.transactionType == 'invoice' || i.transactionType == null;
                                    }).length ??
                                    0;

                            final requestedShoppingCount = shoppingState
                                .shoppingList
                                .where((s) => s.status == 'requested')
                                .length;

                            return TeamMenuSection(
                              invoiceBadgeCount: unpaidInvoicesCount,
                              shoppingBadgeCount: requestedShoppingCount,
                              accountStatus: accountStatus,
                              onInvoiceTap: cubit.navigateToInvoice,
                              onShoppingTap: cubit.navigateToShopping,
                              onAttendanceTap: cubit.navigateToAttendance,
                              onPerformanceTap: cubit.navigateToPerformance,
                              onTalentPoolTap: cubit.navigateToTalentPool,
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.iconXxl),

                // --- SECTION 3: Informasi Terkini (Feed) ---
                TeamFeedSection(onFeedTap: cubit.navigateToFeedDetail),

                const SizedBox(height: 120), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
