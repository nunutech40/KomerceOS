import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import '../widget/app_notification_card.dart';
import '../widget/notification_icon.dart';

class NotificationItem {
  final String category; // 'komship', 'komtim', 'komcards'
  final String title;
  final String? status;
  final Color? statusColor;
  final String date;
  final String time;
  final String message;
  final bool isRead;
  final String group; // 'Hari ini', 'Kemarin'

  const NotificationItem({
    required this.category,
    required this.title,
    this.status,
    this.statusColor,
    required this.date,
    required this.time,
    required this.message,
    required this.isRead,
    required this.group,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChipIndex = 0;
  final List<String> _filterChips = ['Semua', 'Komship', 'Komtim', 'Komcards'];

  // Dummy notification data matching the requested designs
  final List<NotificationItem> _notifications = [
    const NotificationItem(
      category: 'komship',
      title: 'Claim Paket',
      status: 'Disetujui',
      statusColor: Color(0xFF34A853),
      date: '04 April 2026',
      time: '08.30',
      message: 'Klaim paket Paksa RTS dengan nomor order KOM2511071127200892 telah disetujui',
      isRead: false,
      group: 'Hari ini',
    ),
    const NotificationItem(
      category: 'komship',
      title: 'Claim Paket Force Return to Sender',
      status: 'Disetujui',
      statusColor: Color(0xFF34A853),
      date: '04 April 2026',
      time: '08.30',
      message: 'Klaim paket Paksa RTS dengan nomor order KOM2511071127200892 telah disetujui',
      isRead: false,
      group: 'Hari ini',
    ),
    const NotificationItem(
      category: 'komship',
      title: 'Claim Paket Force Return to Sender',
      status: 'Ditolak',
      statusColor: Color(0xFFD63B00),
      date: '04 April 2026',
      time: '08.30',
      message: 'Klaim paket Paksa RTS dengan nomor order KOM2511071127200892 telah ditolak',
      isRead: false,
      group: 'Hari ini',
    ),
    const NotificationItem(
      category: 'komship',
      title: 'Claim Paket Force Return to Sender',
      status: 'Disetujui',
      statusColor: Color(0xFF34A853),
      date: '04 April 2026',
      time: '08.30',
      message: 'Klaim paket Paksa RTS dengan nomor order KOM2511071127200892 telah disetujui',
      isRead: true,
      group: 'Kemarin',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter notifications based on tab and chip selection
    final filtered = _notifications.where((item) {
      // Filter by Tab (Semua vs Belum Dibaca)
      if (_tabController.index == 1 && item.isRead) {
        return false;
      }
      // Filter by Chip (Semua, Komship, Komtim, Komcards)
      if (_selectedChipIndex > 0) {
        final selectedCategory = _filterChips[_selectedChipIndex].toLowerCase();
        if (item.category != selectedCategory) {
          return false;
        }
      }
      return true;
    }).toList();

    // 2. Group the filtered list by their date category ("Hari ini", "Kemarin")
    final Map<String, List<NotificationItem>> grouped = {};
    for (final item in filtered) {
      grouped.putIfAbsent(item.group, () => []).add(item);
    }

    // Keep chronological group order (Hari ini first, then Kemarin)
    final groupKeys = ['Hari ini', 'Kemarin'].where((key) => grouped.containsKey(key)).toList();

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
          // Horizontal scrollable filter chips (Semua, Komship, Komtim, Komcards)
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
                    onTap: () {
                      setState(() {
                        _selectedChipIndex = index;
                      });
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Body content (Notification list or Empty State)
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: groupKeys.length,
                    itemBuilder: (context, gIdx) {
                      final groupName = groupKeys[gIdx];
                      final items = grouped[groupName]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              groupName,
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
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AppNotificationCard(
                                  leading: const NotificationIcon(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Color(0xFFF95E16),
                                      size: 24,
                                    ),
                                  ),
                                  title: item.title,
                                  status: item.status,
                                  statusColor: item.statusColor,
                                  date: item.date,
                                  time: item.time,
                                  message: item.message,
                                  isRead: item.isRead,
                                  onTap: () {
                                    // Mark as read interactive update
                                    setState(() {
                                      final rawIndex = _notifications.indexOf(item);
                                      if (rawIndex != -1) {
                                        _notifications[rawIndex] = NotificationItem(
                                          category: item.category,
                                          title: item.title,
                                          status: item.status,
                                          statusColor: item.statusColor,
                                          date: item.date,
                                          time: item.time,
                                          message: item.message,
                                          isRead: true,
                                          group: item.group,
                                        );
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ],
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