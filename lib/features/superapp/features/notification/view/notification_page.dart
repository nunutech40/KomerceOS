import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/time_convert.dart';

import '../bloc/notification_v2_bloc.dart';
import '../widget/app_notification_card.dart';
import '../widget/notification_icon.dart';
import '../widget/notification_shimmer.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<NotificationV2Bloc>()
        ..add(const FetchNotificationV2Event(isRefresh: true)),
      child: const NotificationPageView(),
    );
  }
}

class NotificationPageView extends StatefulWidget {
  const NotificationPageView({super.key});

  @override
  State<NotificationPageView> createState() => _NotificationPageViewState();
}

class _NotificationPageViewState extends State<NotificationPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChipIndex = 0;
  final List<String> _filterChips = [
    'Semua',
    'Komship',
    'Kompack',
    'Komtim',
    'Komchat',
    'Komcards',
    'Komform',
    'Komplace',
    'Komclass',
    'Pumkm',
    'Komads',
    'Komed',
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final status = _tabController.index == 0 ? '' : 'unread';
        context
            .read<NotificationV2Bloc>()
            .add(FilterStatusChangedEvent(status));
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationV2Bloc>().add(const FetchNotificationV2Event());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChipSelected(int index) {
    setState(() {
      _selectedChipIndex = index;
    });
    final service = _filterChips[index];
    context.read<NotificationV2Bloc>().add(FilterServiceChangedEvent(service));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alwaysWhite,
      appBar: AppBar(
        backgroundColor: AppColors.alwaysWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/superapp/ic_arrow_back.png',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Notifikasi',
          style: AppTypography.headingSm.copyWith(
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Segmented tab layout (Semua / Belum Dibaca)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppTabLayout(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Belum Dibaca'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Horizontal scrollable filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: List.generate(_filterChips.length, (index) {
                final label = _filterChips[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _filterChips.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: DsChipButton(
                    label: label,
                    isSelected: _selectedChipIndex == index,
                    onTap: () => _onChipSelected(index),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Body content
          Expanded(
            child: BlocBuilder<NotificationV2Bloc, NotificationV2State>(
              builder: (context, state) {
                if (state.status == RequestStatus.loading &&
                    state.offset == 0) {
                  // First load: shimmer penuh menggantikan CircularProgressIndicator
                  return const NotificationListShimmer();
                } else if (state.status == RequestStatus.failure &&
                    state.data.isEmpty) {
                  return Center(child: Text(state.message));
                } else if (state.data.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: state.data.length + (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, gIdx) {
                    if (gIdx >= state.data.length) {
                      // Lazy load footer: shimmer 2 item menggantikan CircularProgressIndicator
                      return const NotificationLoadMoreShimmer();
                    }

                    final group = state.data[gIdx];
                    final items = group.data;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            group.dateGroup ?? '',
                            style: AppTypography.bodyMdSemiBold.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, itemIdx) {
                            final item = items[itemIdx];
                            
                            String displayTitle = item.title ?? '';
                            String? displayStatus;
                            Color? displayStatusColor;
                            
                            if (displayTitle.toLowerCase().contains('- ditolak')) {
                              displayStatus = 'Ditolak';
                              displayStatusColor = const Color(0xFFE53935);
                              displayTitle = displayTitle.replaceAll(RegExp(r'\s*-\s*ditolak', caseSensitive: false), '');
                            } else if (displayTitle.toLowerCase().contains('- disetujui')) {
                              displayStatus = 'Disetujui';
                              displayStatusColor = const Color(0xFF34A853);
                              displayTitle = displayTitle.replaceAll(RegExp(r'\s*-\s*disetujui', caseSensitive: false), '');
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppNotificationCard(
                                leading: const NotificationIcon(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.notifications_none,
                                    color: Color(0xFFF95E16),
                                    size: 24,
                                  ),
                                ),
                                title: displayTitle,
                                status: displayStatus,
                                statusColor: displayStatusColor,
                                date: item.createdAt != null
                                    ? dateConvertWithT(item.createdAt!)
                                    : '',
                                time: item.createdAt != null
                                    ? timeConvertWithT(item.createdAt!)
                                    : '',
                                message: item.description ?? '',
                                isRead: item.isRead == 1,
                                onTap: () {
                                  // TODO: Handle notification tap / mark as read
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/superapp/auth/verify_code_email.svg',
            height: 160,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tidak ada notifikasi',
            style: AppTypography.bodyLgSemiBold.copyWith(
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Belum ada informasi apapun disini',
            style: AppTypography.bodyMdRegular.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
