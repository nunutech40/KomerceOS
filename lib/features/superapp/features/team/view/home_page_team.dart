import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/features/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/shopping/bloc/shopping_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/widget/team_action_required_section.dart';
import 'package:komtim_partner/features/superapp/features/team/widget/team_feed_section.dart';
import 'package:komtim_partner/features/superapp/features/team/widget/team_menu_section.dart';

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
      // context.read<InvoiceListBloc>().add(
      //     const InvoviceListPageDidload(type: 'active', limit: 100, offset: 0));
      // context.read<ShoppingBloc>().add(const GetShoppingListEvent(
      //     offset: 0,
      //     limit: 100,
      //     status: "requested",
      //     startDate: "",
      //     endDate: "",
      //     keyword: ""));
      // context
      //     .read<FeedBloc>()
      //     .add(const GetFeedEvent(search: '', offset: 0, limit: 10));
    });
  }

  Future<void> _onRefresh() async {
    context.read<InvoiceListBloc>().add(
        const InvoviceListPageDidload(type: 'active', limit: 100, offset: 0));
    context.read<ShoppingBloc>().add(const GetShoppingListEvent(
        offset: 0,
        limit: 100,
        status: "requested",
        startDate: "",
        endDate: "",
        keyword: ""));
    context
        .read<FeedBloc>()
        .add(const GetFeedEvent(search: '', offset: 0, limit: 10));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: const DsAppBar(
        title: 'Team',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryBase,
          onRefresh: _onRefresh,
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
                        final invoiceCount =
                            invoiceState.invoicesData?.length ?? 0;
                        final shoppingCount = shoppingState.shoppingList.length;

                        return TeamActionRequiredSection(
                          invoiceCount: invoiceCount,
                          shoppingCount: shoppingCount,
                          onInvoiceTap: () {
                            AppRouter.router
                                .pushNamed(PAGES.invoiceList.screenName);
                          },
                          onShoppingTap: () {
                            AppRouter.router
                                .push(PAGES.shoppingListPage.screenPath);
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // --- SECTION 2: Menu Grid ---
                BlocBuilder<InvoiceListBloc, InvoiceListState>(
                  builder: (context, invoiceState) {
                    return BlocBuilder<ShoppingBloc, ShoppingState>(
                      builder: (context, shoppingState) {
                        final invoiceBadge =
                            invoiceState.invoicesData?.length ?? 0;
                        final shoppingBadge = shoppingState.shoppingList.length;

                        return TeamMenuSection(
                          invoiceBadgeCount: invoiceBadge,
                          shoppingBadgeCount: shoppingBadge,
                          onInvoiceTap: () {
                            AppRouter.router
                                .pushNamed(PAGES.invoiceList.screenName);
                          },
                          onShoppingTap: () {
                            AppRouter.router
                                .push(PAGES.shoppingListPage.screenPath);
                          },
                          onAttendanceTap: () {
                            AppRouter.router.push(PAGES.attendance.screenPath);
                          },
                          onPerformanceTap: () {
                            AppRouter.router
                                .push(PAGES.reportperformance.screenPath);
                          },
                          onTalentPoolTap: () {
                            // URL launcher logic can be added here or handled in the new implementation later
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.iconXxl),

                // --- SECTION 3: Informasi Terkini (Feed) ---
                const TeamFeedSection(),

                const SizedBox(height: 120), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
