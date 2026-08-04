import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/invoice_list_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';

part 'home_team_state.dart';

class HomeTeamCubit extends Cubit<HomeTeamState> {
  final InvoiceListBloc invoiceListBloc;
  final ShoppingBloc shoppingBloc;
  final FeedBloc feedBloc;

  HomeTeamCubit({
    required this.invoiceListBloc,
    required this.shoppingBloc,
    required this.feedBloc,
  }) : super(const HomeTeamState());

  /// Dipanggil saat halaman pertama kali dimuat.
  void initialize() {
    _loadData();
  }

  /// Dipanggil saat pull-to-refresh.
  Future<void> refresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _loadData() {
    invoiceListBloc.add(
      const InvoviceListPageDidload(type: 'active', limit: 100, offset: 0),
    );
    shoppingBloc.add(const GetShoppingListEvent(
      offset: 0,
      limit: 100,
      status: 'requested',
      startDate: '',
      endDate: '',
      keyword: '',
    ));
    feedBloc.add(const GetFeedEvent(search: '', offset: 0, limit: 10));
  }

  // ---------------------------------------------------------------------------
  // Navigation actions — semua navigasi terpusat di sini
  // ---------------------------------------------------------------------------

  void navigateToInvoice() {
    AppRouter.router.pushNamed(PAGES.invoiceList.screenName);
  }

  void navigateToShopping() {
    AppRouter.router.push(PAGES.shoppingListPage.screenPath);
  }

  void navigateToAttendance() {
    AppRouter.router.push(PAGES.attendance.screenPath);
  }

  void navigateToPerformance() {
    AppRouter.router.push(PAGES.reportperformance.screenPath);
  }

  void navigateToTalentPool() {
    // Placeholder — tambahkan URL launcher jika diperlukan
  }

  void navigateToFeedDetail(String feedId) {
    AppRouter.router.push(
      PAGES.feeddetail.screenPath,
      extra: feedId,
    );
  }
}
