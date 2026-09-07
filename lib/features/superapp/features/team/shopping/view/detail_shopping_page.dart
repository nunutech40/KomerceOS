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
import 'package:komtim_partner/core/domain/entities/detail_shopping_model.dart';
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
  DetailShoppingDataModel? detailShopping;

  void setupData() async {
    await _bloc.add(GetDetailShoppingEvent(widget.id));
  }

  void _initializeBloc() {
    _bloc = context.read<ShoppingBloc>();
  }

  void _onCancelPressed(int id) async {
    showCancelConfirmation(id);
  }

  void _onPayPressed(int id, bool poin) async {
    showPayConfirmation(id, poin);
  }

  void _onTopupPressed() {
    AppRouter.router.push(PAGES.topuppages.screenPath);
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
    final imageUrl =
        'https://placehold.jp/80/34A853/ffffff/150x150.png?text=${getInitials(name)}';

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
        body: BlocConsumer<ShoppingBloc, ShoppingState>(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(16),
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
                                            detailShopping?.userRequesterName ??
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
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}
