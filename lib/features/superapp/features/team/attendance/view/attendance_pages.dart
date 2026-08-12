import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:komtim_partner/common/global/widgets/custom_showmodal_bottomsheet.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/bloc/attendance_bloc.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/widget/card_no_attendance.dart';
import 'package:komtim_partner/features/superapp/features/team/attendance/widget/card_search_empty_list.dart';

import '../../../../../../common/enum_status.dart';
import '../../../../../../common/global/mixin/handling_error_page.dart';
import '../../../../../../common/global/router/app_router.dart';
import '../../../../../../common/global/widgets/custom_outline_button.dart';
import '../../../../../../common/styles.dart';
import '../../../../../../common/utils/loading/shimmer_placeholder_attendance.dart';
import '../widget/card_attendance.dart';
import '../widget/card_empty_list.dart';
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
            appBar: AppBar(
              title: const Text('Report Presensi',
                  style: AppTypography.interSemiBold16),
              leading: IconButton(
                icon: SvgPicture.asset('assets/images/ic-arrow-left.svg'),
                onPressed: () {
                  AppRouter.router.pop();
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(180),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: primaryColor,
                        labelColor: primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: onlyGray,
                        padding: EdgeInsets.zero,
                        onTap: ((value) {
                          showHiddenButton(value);
                        }),
                        tabs: const [
                          Tab(
                            child: Center(
                              child: Text(
                                "Hadir",
                                textAlign: TextAlign.center,
                                style: AppTypography.interRegular14,
                              ),
                            ),
                          ),
                          Tab(
                            child: Center(
                              child: Text(
                                "Tidak Hadir",
                                textAlign: TextAlign.center,
                                style: AppTypography.interRegular14,
                              ),
                            ),
                          ),
                          Tab(
                            child: Center(
                              child: Text(
                                "Gagal Presensi",
                                textAlign: TextAlign.center,
                                style: AppTypography.interRegular14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        margin:
                            const EdgeInsets.only(top: 24, left: 24, right: 24),
                        padding: const EdgeInsets.only(left: 10.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: backgroundContainerColor),
                        child: InkWell(
                          onTap: () {
                            // _selectDate(context);
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CustomShowModalBottomSheet(
                                    context: context,
                                    selectedDate: selectedDate,
                                    value: valueFilter,
                                    textEditor: _textEditingController.text,
                                  );
                                }).then((value) {
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
                          child: TextField(
                            style: AppTypography.regular14,
                            decoration: InputDecoration(
                                suffixIconConstraints: const BoxConstraints(
                                  minHeight: 20,
                                  minWidth: 20,
                                ),
                                enabled: false,
                                border: InputBorder.none,
                                hintStyle: statusFilter == 'all'
                                    ? AppTypography.regular14inActive
                                    : AppTypography.regular14Active,
                                hintText: statusFilterString(statusFilter),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: SvgPicture.asset(
                                      "assets/images/ic_calendar-add.svg",
                                      width: 20,
                                      height: 20),
                                )),
                          ),
                        )),
                    Container(
                        margin:
                            const EdgeInsets.only(top: 8, left: 24, right: 24),
                        padding: const EdgeInsets.only(left: 10.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: backgroundContainerColor),
                        child: TextField(
                          controller: _textEditingController,
                          style: AppTypography.regular14,
                          decoration: InputDecoration(
                              suffixIconConstraints: const BoxConstraints(
                                minHeight: 20,
                                minWidth: 20,
                              ),
                              border: InputBorder.none,
                              hintStyle: AppTypography.regular14inActive,
                              hintText: 'Cari Nama Talent',
                              suffixIcon: Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                    "assets/images/ic_search.svg",
                                    width: 20,
                                    height: 20),
                              )),
                        ))
                  ],
                ),
              ),
            ),
            body: Container(
              margin: const EdgeInsets.only(left: 24, right: 24, top: 15),
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
                                date: listDataAttendance[index].checkInDatetime,
                                imagesClockIn:
                                    listDataAttendance[index].checkInPhotoUrl,
                                imagesClockOut:
                                    listDataAttendance[index].checkOutPhotoUrl,
                                clockIn:
                                    listDataAttendance[index].checkInDatetime,
                                clockOut:
                                    listDataAttendance[index].checkOutDatetime,
                                index: index,
                              );
                              // Tampilkan data
                            } else if (_isLoading) {
                              return ShimmerPlaceholderAttendance(index: index);
                            } else if (_hasNextPage == true && _isLoadingMore) {
                              return Column(children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: const CircularProgressIndicator(
                                    color: primaryColor,
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
                              if (_textEditingController.text.isNotEmpty ||
                                  statusFilter != 'all') {
                                return CardSearchEmptyList(
                                  onPressed: () {
                                    _textEditingController.clear();
                                    statusFilter = 'all';
                                    getDate();
                                    _loadData();
                                    setState(() {});
                                  },
                                );
                              } else {
                                return const CardEmptyList();
                              }
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
                    child: Center(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: listDataAttendanceAbsence.length + 1,
                        itemBuilder: (context, index) {
                          if (index < listDataAttendanceAbsence.length) {
                            return CardNoAttendance(
                              name: listDataAttendanceAbsence[index].fullName,
                              date:
                                  listDataAttendanceAbsence[index].absenceDate,
                              index: index,
                              length: listDataAttendanceAbsence.length,
                            );
                          } else if (_isLoading) {
                            return const ShimmerPlaceholderAbasence();
                          } else if (listDataAttendanceAbsence.isEmpty &&
                              state.statusAttendanceAbsence ==
                                  RequestStatus.success) {
                            if (_textEditingController.text.isNotEmpty ||
                                statusFilter != 'all') {
                              return CardSearchEmptyList(
                                onPressed: () {
                                  _textEditingController.clear();
                                  statusFilter = 'all';
                                  getDate();
                                  _loadDataAbsence();
                                  setState(() {});
                                },
                              );
                            } else {
                              return const CardEmptyList();
                            }
                          }
                          return null;
                        },
                      ),
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
                                name: listDataAttendanceFail[index].fullName,
                                date: listDataAttendanceFail[index].createdAt,
                                deskripsi:
                                    listDataAttendanceFail[index].description,
                                index: index,
                              ),
                            );
                          } else if (_isLoading) {
                            return ShimmerPlaceholderPresenceFail(index: index);
                          } else if (_hasNextPage == true && _isLoadingMore) {
                            return Column(children: [
                              Container(
                                height: 20,
                                width: 20,
                                margin: const EdgeInsets.only(top: 10),
                                child: const CircularProgressIndicator(
                                  color: primaryColor,
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
                            if (_textEditingController.text.isNotEmpty ||
                                statusFilter != 'all') {
                              return CardSearchEmptyList(
                                onPressed: () {
                                  _textEditingController.clear();
                                  statusFilter = 'all';
                                  getDate();
                                  _loadDataFail();
                                  setState(() {});
                                },
                              );
                            } else {
                              return const CardEmptyList();
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: button == true
                ? Container(
                    color: Colors.white,
                    child: Container(
                      height: 88.0,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0,
                              -1), // Shadow position, negative y value to place at the top
                        ),
                      ], color: Colors.white),
                      child: Center(
                        child: SafeArea(
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                width: MediaQuery.of(context).size.width,
                                height: 55,
                                child: listDataAttendance.isNotEmpty
                                    ? Container(
                                        child: _isloadingDownload == false
                                            ? CustomOutlineButton(
                                                icon: SvgPicture.asset(
                                                    "assets/images/ic_export.svg"),
                                                text: 'Export',
                                                onPressed: () async {
                                                  _isloadingDownload = true;
                                                  ceckMessageDownload = true;

                                                  await _bloc.add(
                                                      DownloadAttendanceEvent(
                                                          startDate: firstDate,
                                                          endDate: lastDate));
                                                },
                                                color: Colors.white,
                                                backGroundColor: primaryColor,
                                              )
                                            : CustomOutlineButton(
                                                text: '',
                                                onPressed: () async {},
                                                isLoading: true,
                                                color: Colors.white,
                                                backGroundColor: Colors.grey,
                                              ),
                                      )
                                    : CustomOutlineButton(
                                        icon: SvgPicture.asset(
                                            "assets/images/ic_export.svg"),
                                        text: 'Export',
                                        onPressed: () {},
                                        color: Colors.white,
                                        backGroundColor: e2Gray,
                                      ))),
                      ),
                    ))
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
    valueFilter = 0;
    statusFilter = "all";
    _textEditingController.clear();
    await refreshData();
    _loadData();
  }

  /// function for second tab
  _secondTabFunction() async {
    statTab = 1;
    valueFilter = 0;
    statusFilter = "all";
    _textEditingController.clear();
    await refreshData();
    _loadDataAbsence();
  }

  /// function for third tab
  _thirdTabFunction() async {
    statTab = 2;
    valueFilter = 0;
    statusFilter = "all";
    _textEditingController.clear();
    await refreshData();
    _loadDataFail();
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
