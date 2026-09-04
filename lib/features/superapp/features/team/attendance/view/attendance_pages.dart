import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/global/design_system/design_system.dart';
import 'package:komtim_partner/common/global/widgets/custom_showmodal_bottomsheet.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/bloc/attendance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/widget/card_no_attendance.dart';

import '../../../../../../common/enum_status.dart';
import '../../../../../../common/global/mixin/handling_error_page.dart';
import '../../../../../../common/utils/loading/shimmer_placeholder_attendance.dart';
import '../widget/card_attendance.dart';
import '../widget/fail_attendance_card.dart';
import '../widget/shimmer_place_holder.dart';
import '../widget/shimmer_place_holder_fail.dart';

class AttendancePages extends StatefulWidget {
  const AttendancePages({super.key});

  @override
  State<AttendancePages> createState() => _AttendancePagesState();
}

class _AttendancePagesState extends State<AttendancePages>
    with TickerProviderStateMixin, ErrorHandlingMixin {
  TabController? _tabController;
  final _textEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool button = true;
  var _bloc;

  List<dynamic> listDataAttendance = [];
  List<dynamic> listDataAttendanceFail = [];
  List<dynamic> listDataAttendanceAbsence = [];

  String firstDate = '';
  String lastDate = '';
  String statusFilter = 'all';
  bool ceckMessageDownload = false;
  int? valueFilter = 0;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerAttendanceFail = ScrollController();

  int _offset = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isloadingDownload = false;
  bool _hasNextPage = true;
  int maxAttempts = 3;
  int attemptCount = 0;
  int statTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 3);
    getDate();
    _initializeBloc();
    _loadData();
    // Tambahkan listener untuk mendeteksi scroll ke bawah
    _textEditingController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _scrollControllerAttendanceFail.addListener(_scrollListenerAttendanceFail);
    _tabController?.addListener(_handleTabSelection);
    _offset = 0;
  }

  @override
  void dispose() {
    // Hapus listener saat widget dihapus
    _scrollController.removeListener(_scrollListener);
    _scrollControllerAttendanceFail
        .removeListener(_scrollListenerAttendanceFail);
    _tabController?.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (statTab == 0) {
          if (_isloadingDownload == true) {
            // print("waiting download....");
          } else {
            handleListenerPrecense(context, state);
          }
          handleListenerDownload(context, state);
        } else if (statTab == 1) {
          handleListenerAbsence(context, state);
        } else if (statTab == 2) {
          handleListenerFail(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: const DsAppBar(title: 'Report Presensi'),
            backgroundColor: AppColors.alwaysWhite,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      AppTabLayout(
                        controller: _tabController,
                        variant: AppTabLayoutVariant.elevated,
                        onTap: showHiddenButton,
                        tabs: const [
                          Tab(text: 'Hadir'),
                          Tab(text: 'Tidak Hadir'),
                          Tab(text: 'Gagal Presensi'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Search + date filter
                      Row(
                        children: [
                          Expanded(
                            child: DsSearchField(
                              controller: _textEditingController,
                              hintText: 'Cari Nama Talent',
                              onChanged: (_) => _onSearchChanged(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          DsSquareIconButton(
                            customIcon: SvgPicture.asset(
                              'assets/images/team/ic_calender.svg',
                              width: 20,
                              height: 20,
                            ),
                            isActive: statusFilter != 'all',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CustomShowModalBottomSheet(
                                    context: context,
                                    selectedDate: selectedDate,
                                    value: valueFilter,
                                    textEditor: _textEditingController.text,
                                    firstDate: firstDate,
                                    lastDate: lastDate,
                                    statusFilterValue: statusFilter,
                                  );
                                },
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    firstDate = value['firstDate'];
                                    lastDate = value['lastDate'];
                                    statusFilter = value['statusFilter'];
                                    valueFilter = value['value'];
                                    _textEditingController.text =
                                        value['textEditor'];
                                    listDataAttendance.clear();
                                    listDataAttendanceAbsence.clear();
                                    listDataAttendanceFail.clear();
                                    _offset = 0;
                                    attemptCount = 0;
                                    _hasNextPage = true;
                                    if (statTab == 0) {
                                      _loadData();
                                    } else if (statTab == 1) {
                                      _loadDataAbsence();
                                    } else if (statTab == 2) {
                                      _loadDataFail();
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.sm,
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        RefreshIndicator(
                            onRefresh: () async {
                              await refreshData();
                              _loadData();
                            },
                            child: Center(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 50),
                                controller: _scrollController,
                                itemCount: listDataAttendance.length + 1,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (index < listDataAttendance.length) {
                                    return CardAttendance(
                                      name: listDataAttendance[index].fullName,
                                      type: listDataAttendance[index].workMode,
                                      date: listDataAttendance[index]
                                          .checkInDatetime,
                                      imagesClockIn: listDataAttendance[index]
                                          .checkInPhotoUrl,
                                      imagesClockOut: listDataAttendance[index]
                                          .checkOutPhotoUrl,
                                      clockIn: listDataAttendance[index]
                                          .checkInDatetime,
                                      clockOut: listDataAttendance[index]
                                          .checkOutDatetime,
                                      index: index,
                                    );
                                    // Tampilkan data
                                  } else if (_isLoading) {
                                    return ShimmerPlaceholderAttendance(
                                        index: index);
                                  } else if (_hasNextPage == true &&
                                      _isLoadingMore) {
                                    return Column(children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        margin: const EdgeInsets.only(top: 10),
                                        child: const CircularProgressIndicator(
                                          color: AppColors.primaryBase,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      const Text("Loading")
                                    ]);
                                  } else if (listDataAttendance.isEmpty &&
                                      state.statusAttendance ==
                                          RequestStatus.success) {
                                    return const DsEmptyState(
                                      imagePath:
                                          'assets/images/team/empty_state_feed.svg',
                                      title: 'Tidak Ada Data Tersedia',
                                      description:
                                          'Belum ada talent yang hadir',
                                    );
                                  }
                                  return null;
                                },
                              ),
                            )),
                        RefreshIndicator(
                          onRefresh: () async {
                            await refreshData();
                            _loadDataAbsence();
                          },
                          child: _isLoading
                              ? const Center(
                                  child: ShimmerPlaceholderAbasence(),
                                )
                              : listDataAttendanceAbsence.isEmpty &&
                                      state.statusAttendanceAbsence ==
                                          RequestStatus.success
                                  ? ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        DsEmptyState(
                                          imagePath:
                                              'assets/images/team/empty_state_feed.svg',
                                          title: 'Tidak Ada Data Tersedia',
                                          description:
                                              'Belum ada talent yang hadir',
                                        ),
                                      ],
                                    )
                                  : ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.alwaysWhite,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.05),
                                                blurRadius: 9,
                                                spreadRadius: 0.3,
                                                offset: Offset.zero,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: List.generate(
                                                listDataAttendanceAbsence
                                                    .length,
                                                (index) => CardNoAttendance(
                                                  name:
                                                      listDataAttendanceAbsence[
                                                              index]
                                                          .fullName,
                                                  date:
                                                      listDataAttendanceAbsence[
                                                              index]
                                                          .absenceDate,
                                                  index: index,
                                                  length:
                                                      listDataAttendanceAbsence
                                                          .length,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await refreshData();
                            _loadDataFail();
                          },
                          child: Center(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 50),
                              controller: _scrollControllerAttendanceFail,
                              itemCount: listDataAttendanceFail.length + 1,
                              itemBuilder: (context, index) {
                                if (index < listDataAttendanceFail.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: FailAttendanceCard(
                                      name: listDataAttendanceFail[index]
                                          .fullName,
                                      date: listDataAttendanceFail[index]
                                          .createdAt,
                                      deskripsi: listDataAttendanceFail[index]
                                          .description,
                                      index: index,
                                    ),
                                  );
                                } else if (_isLoading) {
                                  return ShimmerPlaceholderPresenceFail(
                                      index: index);
                                } else if (_hasNextPage == true &&
                                    _isLoadingMore) {
                                  return Column(children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      margin: const EdgeInsets.only(top: 10),
                                      child: const CircularProgressIndicator(
                                        color: AppColors.primaryBase,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    const Text("Loading")
                                  ]);
                                } else if (listDataAttendanceFail.isEmpty &&
                                    state.statusAttendanceFail ==
                                        RequestStatus.success) {
                                  return const DsEmptyState(
                                    imagePath:
                                        'assets/images/team/empty_state_feed.svg',
                                    title: 'Tidak Ada Data Tersedia',
                                    description: 'Belum ada talent yang hadir',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: button == true
                ? Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: SafeArea(
                      child: DsButton(
                        text: 'Export',
                        leftIcon: SvgPicture.asset(
                          'assets/images/ic_export.svg',
                          width: 20,
                          height: 20,
                        ),
                        state: listDataAttendance.isEmpty
                            ? DsButtonState.disabled
                            : (_isloadingDownload
                                ? DsButtonState.loading
                                : DsButtonState.enabled),
                        onPressed: () async {
                          _isloadingDownload = true;
                          ceckMessageDownload = true;

                          await _bloc.add(
                            DownloadAttendanceEvent(
                              startDate: firstDate,
                              endDate: lastDate,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : null);
      },
    );
  }

  /// initialize bloc
  void _initializeBloc() {
    _bloc = context.read<AttendanceBloc>();
  }

  /// get date now
  getDateNow() async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    firstDate = formatter.format(now);
    lastDate = formatter.format(now);
  }

  /// get date await
  getDate() async {
    await getDateNow();
  }

  /// scroll listener for load more data
  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasNextPage) {
      _loadMoreData();
    }
  }

  /// scroll listener for load more data
  void _scrollListenerAttendanceFail() {
    if (_scrollControllerAttendanceFail.position.pixels ==
            _scrollControllerAttendanceFail.position.maxScrollExtent &&
        _hasNextPage) {
      _loadMoreDataAttendanceFail();
    }
  }

  /// load data attendance
  Future<void> _loadData() async {
    _isLoading = true;

    await _bloc.add(GetAttendanceEvent(
        offset: _offset,
        limit: _limit,
        name: _textEditingController.text,
        startDate: firstDate,
        endDate: lastDate));
  }

  /// load more data attendance
  Future<void> _loadMoreData() async {
    if (_hasNextPage == false) return;
    _isLoadingMore = true;
    _offset += _limit;

    final moreData = await _bloc.add(GetAttendanceEvent(
        offset: _offset,
        limit: _limit,
        name: _textEditingController.text,
        startDate: firstDate,
        endDate: lastDate));

    listDataAttendance.addAll(moreData);
    _isLoadingMore = false;
  }

  /// load more data attendance
  Future<void> _loadMoreDataAttendanceFail() async {
    if (_hasNextPage == false) return;
    _isLoadingMore = true;

    _offset += _limit;

    final moreData = await _bloc.add(GetAttendanceFailEvent(
        offset: _offset,
        limit: _limit,
        name: _textEditingController.text,
        startDate: firstDate,
        endDate: lastDate));
    listDataAttendanceFail.addAll(moreData);
    _isLoadingMore = false;
  }

  /// refresh data
  refreshData() async {
    if (statusFilter != 'all' || _textEditingController.text != '') {
      _isLoading = true;
      listDataAttendance.clear();
      listDataAttendanceAbsence.clear();
      listDataAttendanceFail.clear();
      _offset = 0;
      attemptCount = 0;
      _hasNextPage = true;
      setState(() {});
    } else {
      _isLoading = true;
      listDataAttendance.clear();
      listDataAttendanceAbsence.clear();
      listDataAttendanceFail.clear();
      statusFilter = 'all';
      _textEditingController.clear();
      _offset = 0;
      attemptCount = 0;
      _hasNextPage = true;
      valueFilter = 0;
      await getDate();
      setState(() {});
    }
  }

  /// on search changed listener
  void _onSearchChanged() async {
    _isLoading = true;
    if (statTab == 0 && _textEditingController.text.isNotEmpty) {
      listDataAttendance.clear();
      _offset = 0;
      attemptCount = 0;
      _hasNextPage = true;
      Future.delayed(
          const Duration(seconds: 5),
          _bloc.add(GetAttendanceEvent(
              offset: _offset,
              limit: _limit,
              name: _textEditingController.text,
              startDate: firstDate,
              endDate: lastDate)));
    } else if (statTab == 1 && _textEditingController.text.isNotEmpty) {
      listDataAttendanceAbsence.clear();
      Future.delayed(
          const Duration(seconds: 5),
          _bloc.add(GetAttendanceAbsenceEvent(
              name: _textEditingController.text,
              startDate: firstDate,
              endDate: lastDate)));
    } else if (statTab == 2 && _textEditingController.text.isNotEmpty) {
      listDataAttendanceFail.clear();
      _offset = 0;
      attemptCount = 0;
      _hasNextPage = true;
      Future.delayed(
          const Duration(seconds: 5),
          _bloc.add(GetAttendanceFailEvent(
              offset: _offset,
              limit: _limit,
              name: _textEditingController.text,
              startDate: firstDate,
              endDate: lastDate)));
    }
  }

  /// load data absence
  Future<void> _loadDataAbsence() async {
    _isLoading = true;

    await _bloc.add(GetAttendanceAbsenceEvent(
        name: _textEditingController.text,
        startDate: firstDate,
        endDate: lastDate));
  }

  /// load data attendance fail
  Future<void> _loadDataFail() async {
    _isLoading = true;

    await _bloc.add(GetAttendanceFailEvent(
        offset: _offset,
        limit: _limit,
        name: _textEditingController.text,
        startDate: firstDate,
        endDate: lastDate));
  }

  /// handle listener presence
  handleListenerPrecense(BuildContext context, AttendanceState state) {
    if (state.statusAttendance == RequestStatus.success &&
        state.attendanceData.isNotEmpty) {
      listDataAttendance.addAll(state.attendanceData);
      listDataAttendance
          .sort((a, b) => b.checkInDatetime.compareTo(a.checkInDatetime));
      _isLoading = false;
      attemptCount = 0;
    }

    if (state.attendanceData.isEmpty &&
        state.statusAttendance == RequestStatus.success) {
      _isLoading = false;
      _isLoadingMore = false;
      attemptCount++;
      if (attemptCount == maxAttempts && ceckMessageDownload == false) {
        _hasNextPage = false;
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data sudah habis")),
        );
      }
    }
  }

  /// handle listener absence
  handleListenerAbsence(BuildContext context, AttendanceState state) {
    if (state.statusAttendanceAbsence == RequestStatus.success &&
        state.attendanceAbsenceData.isNotEmpty) {
      listDataAttendanceAbsence.addAll(state.attendanceAbsenceData);
      listDataAttendanceAbsence
          .sort((a, b) => b.absenceDate.compareTo(a.absenceDate));
      _isLoading = false;
      _offset = listDataAttendanceAbsence.length;
      attemptCount = 0;
    }
    if (state.attendanceAbsenceData.isEmpty &&
        state.statusAttendanceAbsence == RequestStatus.success) {
      _isLoading = false;
    }
  }

  /// handle listener absence
  handleListenerFail(BuildContext context, AttendanceState state) {
    if (state.statusAttendanceFail == RequestStatus.success &&
        state.attendanceFailData.isNotEmpty) {
      listDataAttendanceFail.addAll(state.attendanceFailData);
      listDataAttendanceFail.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      attemptCount = 0;
    }

    if (state.attendanceFailData.isEmpty &&
        state.statusAttendanceFail == RequestStatus.success) {
      _isLoading = false;
      _isLoadingMore = false;
      attemptCount++;
      if (attemptCount == maxAttempts && ceckMessageDownload == false) {
        _hasNextPage = false;
        _isLoadingMore = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data sudah habis")),
        );
      }
    }
  }

  handleListenerDownload(BuildContext context, AttendanceState state) {
    if (state.statusDownloadAttendance == RequestStatus.success &&
        _isloadingDownload == true) {
      _isloadingDownload = false;
      ceckMessageDownload = false;
    } else if (state.statusDownloadAttendance == RequestStatus.failure &&
        _isloadingDownload == true) {
      _isloadingDownload = false;
      ceckMessageDownload = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download gagal")),
      );
    }
  }

  /// status filter string
  String statusFilterString(String status) {
    if (status == 'all') {
      return 'Hari ini';
    } else if (status == 'today') {
      return 'Hari Ini';
    } else if (status == 'week') {
      return '7 Hari Terakhir';
    } else if (status == 'month') {
      return '30 Hari Terakhir';
    } else if (status == 'custom') {
      return '${firstDate.replaceAll('-', '/')} - ${lastDate.replaceAll('-', '/')}';
    } else {
      return 'Hari ini';
    }
  }

  ///handle tab selection
  void _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      if (_tabController!.index == 0) {
        _firstTabFunction();
      } else if (_tabController!.index == 1) {
        _secondTabFunction();
      } else if (_tabController!.index == 2) {
        _thirdTabFunction();
      }
    }
  }

  /// function for first tab
  _firstTabFunction() async {
    statTab = 0;
    listDataAttendance.clear();
    _offset = 0;
    attemptCount = 0;
    _hasNextPage = true;
    await _loadData();
  }

  /// function for second tab
  _secondTabFunction() async {
    statTab = 1;
    listDataAttendanceAbsence.clear();
    _offset = 0;
    attemptCount = 0;
    _hasNextPage = true;
    await _loadDataAbsence();
  }

  /// function for third tab
  _thirdTabFunction() async {
    statTab = 2;
    listDataAttendanceFail.clear();
    _offset = 0;
    attemptCount = 0;
    _hasNextPage = true;
    await _loadDataFail();
  }

  /// show hidden button
  showHiddenButton(int value) {
    if (value == 0) {
      button = true;
    } else {
      button = false;
    }
    setState(() {});
  }
}
