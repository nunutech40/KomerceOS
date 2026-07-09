import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/features/notifications/bloc/notification_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/mixin/handling_error_page.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/styles.dart';
import '../../../common/utils/loading/shimmer_placeholder_invoice_list.dart';
import '../widget/notification_item.dart';

class NotificationPage extends StatefulWidget {
  final String? statusAccount;
  const NotificationPage({Key? key, required this.statusAccount})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with ErrorHandlingMixin {
  var _bloc;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    loadData();
  }

  void _initializeBloc() {
    _bloc = context.read<NotificationBloc>();
  }

  void loadData() async {
    await _bloc.add(const NotificationDataLoad());
  }

  void readNotification(int? id) async {
    await _bloc.add(GetNotificationReadEvent(id: id ?? 0));
  }

  void refreshData() async {
    await _bloc.add(const RefreshDataEvent());
  }

  // Define the _handleRefresh method
  Future<void> _handleRefresh() async {
    refreshData();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.label_notif,
          style: AppTypography.interSemiBold16.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
          onPressed: () {
            AppRouter.router.pop();
          },
        ),
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.status == RequestStatus.failure) {
            handleFailureState(context, state, state.message);
          }
        },
        builder: (context, state) {
          final dataNotifications = state.notificationData ?? [];

          if (state.status == RequestStatus.success &&
              dataNotifications.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: dataNotifications.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    if (dataNotifications[index].notificationType == 18) {
                      readNotification(dataNotifications[index].notificationId);
                      loadData();
                      AppRouter.router.push(PAGES.feeddetail.screenPath,
                          extra: dataNotifications[index].targetId.toString());
                    } else {
                      readNotification(dataNotifications[index].notificationId);
                      loadData();
                      AppRouter.router.pushNamed(
                        PAGES.invoiceReportSummary.screenName,
                        queryParameters: {
                          'invoiceCode':
                              dataNotifications[index].invoiceCode.toString(),
                          'statusAccount': widget.statusAccount
                        },
                      );
                    }
                  },
                  child: NotificationItem(
                    dataModel: dataNotifications[index],
                  ),
                ),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 0,
                  );
                },
              ),
            );
          } else if (state.status == RequestStatus.loading) {
            return const ShimmerPlaceholderInvoiceList();
          } else if (dataNotifications.isEmpty) {
            return const Center(child: Text(Strings.label_no_data));
          } else {
            return Container(); // Fallback in case no other conditions match.
          }
        },
      ),
    );
  }
}
