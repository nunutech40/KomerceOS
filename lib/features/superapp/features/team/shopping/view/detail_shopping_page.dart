import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/design_system/components/ds_app_bar.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/core/domain/entities/balance_analytics_model.dart';
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
import 'package:komtim_partner/core/domain/entities/profile_model.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/bloc/payment_method_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/invoice/widget/bottom_sheet_balance.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/bloc/shopping_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/confirmation_cancel.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/confirmation_pay.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/detail_list.dart';
import 'package:komtim_partner/features/superapp/features/team/shopping/widget/option_requested.dart';

class DetailShoppingPage extends StatefulWidget {
  final int id;
  const DetailShoppingPage({Key? key, required this.id}) : super(key: key);

  @override
  State<DetailShoppingPage> createState() => _DetailShoppingPageState();
}

class _DetailShoppingPageState extends State<DetailShoppingPage>
    with ErrorHandlingMixin {
  var _bloc;
  late PaymentMethodBloc _paymentBloc;
  DetailShoppingDataModel? detailShopping;

  // Data balance yang di-fetch via PaymentMethodBloc
  ProfileModel? _profileData;
  DashboardBalanceDataModel? _balanceData;

  // Pending payment: disimpan saat user klik "Bayar" tapi data belum siap.
  // Setelah data balance selesai di-fetch, cek langsung dieksekusi.
  int? _pendingPayId;
  bool? _pendingPoin;

  // Loading state: true saat sedang fetch profile + balance analytics.
  bool _isCheckingBalance = false;

  void setupData() async {
    await _bloc.add(GetDetailShoppingEvent(widget.id));
  }

  void _initializeBloc() {
    _bloc = context.read<ShoppingBloc>();
    _paymentBloc = context.read<PaymentMethodBloc>();
  }

  void _onCancelPressed(int id) async {
    showCancelConfirmation(id);
  }

  /// Tombol "Bayar" diklik.
  /// Selalu fetch data terbaru dari API sebelum cek saldo.
  /// Tidak pakai cache karena saldo bisa berubah kapan saja
  /// (misal setelah topup atau transaksi lain).
  void _onPayPressed(int id, bool poin) {
    _pendingPayId = id;
    _pendingPoin = poin;
    // Reset data lama agar selalu pakai data fresh dari server.
    _profileData = null;
    _balanceData = null;
    // Tampilkan loading di button Bayar.
    setState(() => _isCheckingBalance = true);
    _paymentBloc.add(const GetProfileEvent());
  }

  /// Evaluasi saldo — sama persis dengan logika di PaymentMethodPage.
  /// Panggil ini setelah _profileData dan _balanceData dipastikan non-null.
  void _checkBalanceAndPay(int id, bool poin) {
    // Selesai fetch → matikan loading.
    setState(() => _isCheckingBalance = false);

    final amountTotal = detailShopping?.total ?? 0;
    final kmPoin = _profileData?.kmPoin ?? 0;
    final idealBalance = _balanceData?.idealBalance ?? 0;
    final onWithdrawl = _balanceData?.onWithdrawl ?? 0;

    if (amountTotal > kmPoin - idealBalance) {
      _showBalanceBottomSheet(type: 1);
    } else if (amountTotal > kmPoin - onWithdrawl) {
      _showBalanceBottomSheet(type: 2);
    } else if (amountTotal > kmPoin - idealBalance - onWithdrawl) {
      _showBalanceBottomSheet(type: 3);
    } else {
      // Saldo mencukupi → tampilkan dialog konfirmasi bayar.
      showPayConfirmation(id, poin);
    }
  }

  /// Tampilkan BottomSheet peringatan saldo tidak mencukupi.
  void _showBalanceBottomSheet({required int type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetBalance(type: type, data: _balanceData),
    );
  }

  void _onTopupPressed() {
    final shoppingId = widget.id;
    // Pass callback sebagai GoRouter extra agar TopupPage (dan sub-pages)
    // bisa kembali ke halaman belanja setelah topup berhasil.
    AppRouter.router.push(
      PAGES.topuppages.screenPath,
      extra: () {
        // Topup berhasil: kembali ke detail shopping.
        // Gunakan GoRouter.go (replace seluruh stack) ke detail shopping
        // dengan id yang sama agar data di-reload dari awal dengan saldo baru.
        AppRouter.router.goNamed(
          PAGES.detailShoppingPage.screenName,
          queryParameters: {'id': '$shoppingId'},
        );
      } as VoidCallback,
    );
  }

  void showCancelConfirmation(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationCancel(
          onYesPressed: () {
            AppRouter.router.pop();
            _bloc.add(CancelShoppingEvent(id));
          },
          onNoPressed: () {
            AppRouter.router.pop();
          },
          textConfirmation: Strings.dialog_reject_shopping,
        );
      },
    );
  }

  void showPayConfirmation(int id, bool poin) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationPay(
          onYesPressed: () {
            AppRouter.router.pop();
            _bloc.add(PayShoppingEvent(id, poin));
          },
          onNoPressed: () {
            AppRouter.router.pop();
          },
          textConfirmation: Strings.dialog_approve_shopping,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    setupData();
  }

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'No Name';
    }

    final names = name.trim().split(" ");
    if (names.isEmpty) {
      return 'No Name';
    }

    if (names.length > 1) {
      final firstName = names[0];
      final lastName = names[names.length - 1];
      return "${firstName[0]}${lastName[0]}";
    } else {
      return names[0][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = detailShopping?.userRequesterName ?? 'No Name';

    return WillPopScope(
      onWillPop: () async {
        AppRouter.router.pop();
        return false;
      },
      child: Scaffold(
        appBar: DsAppBar(
          title: 'Belanja',
          onBackPressed: () {
            AppRouter.router.pop();
          },
        ),
        body: MultiBlocListener(
          listeners: [
            // Listener untuk ShoppingBloc (operasi cancel/pay/load detail)
            BlocListener<ShoppingBloc, ShoppingState>(
              listener: (context, state) {
                if (state.status == RequestStatus.success) {
                  if (state.operation == 'cancelShopping') {
                    AppRouter.router.push(PAGES.shoppingListPage.screenPath);
                  } else if (state.operation == 'payShopping') {
                    AppRouter.router.push(PAGES.shoppingListPage.screenPath);
                  }
                  setState(() {
                    detailShopping = state.detailShopping;
                  });
                } else if (state.shoppingList.isEmpty) {}

                if (state.status == RequestStatus.failure) {
                  handleFailureState(context, state, state.message);
                }
              },
            ),
            // Listener untuk PaymentMethodBloc (fetch profile & balance analytics)
            BlocListener<PaymentMethodBloc, PaymentMethodState>(
              listener: (context, state) {
                if (state.status == RequestStatus.success) {
                  if (state.operation == 'getProfile') {
                    // Profile berhasil → simpan dan lanjut fetch balance analytics.
                    setState(() => _profileData = state.profileData);
                    _paymentBloc.add(
                      GetBalanceAnalyticsEvent(
                        id: state.profileData?.partnerId,
                      ),
                    );
                  } else if (state.operation == 'getBalanceAnalytics') {
                    // Balance analytics berhasil → simpan data.
                    setState(() => _balanceData = state.balanceData);

                    // Jika ada pending payment (user klik "Bayar" sebelum data
                    // siap), eksekusi cek saldo sekarang.
                    if (_pendingPayId != null && _pendingPoin != null) {
                      final id = _pendingPayId!;
                      final poin = _pendingPoin!;
                      // Reset pending sebelum eksekusi untuk hindari double-call.
                      _pendingPayId = null;
                      _pendingPoin = null;
                      _checkBalanceAndPay(id, poin);
                    }
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<ShoppingBloc, ShoppingState>(
            builder: (context, state) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 0, 24),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          getInitials(name).toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              detailShopping
                                                      ?.userRequesterName ??
                                                  '',
                                              style: const TextStyle(
                                                color: AppColors.black0A0A,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              detailShopping
                                                      ?.userRequesterPosition ??
                                                  '',
                                              style: const TextStyle(
                                                color: gray737373,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DetailList(
                                  detailShopping: state.detailShopping,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  detailShopping?.status == 'requested'
                      ? OptionRequested(
                          onCancelPressed: _onCancelPressed,
                          dataShopping: detailShopping,
                          onPayPressed: _onPayPressed,
                          onTopupPressed: _onTopupPressed,
                          isLoadingPay: _isCheckingBalance,
                        )
                      : Container(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
