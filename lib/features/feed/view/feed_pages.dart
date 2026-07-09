import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/global/router/app_router.dart';
import 'package:komtim_partner/common/global/router/router_utils.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/shimmer_placeholder_invoice_list.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/features/feed/bloc/feed_bloc.dart';
import 'package:komtim_partner/features/feed/widget/card_list_all_feed.dart';
import 'package:komtim_partner/features/home/widget/card_feed_empty.dart';

class FeedPages extends StatefulWidget {
  const FeedPages({super.key});

  @override
  State<FeedPages> createState() => _FeedPagesState();
}

class _FeedPagesState extends State<FeedPages> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var _bloc;
  int offset = 0;
  int limit = 10;
  int maxAttempts = 3;
  int attemptCount = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNextPage = true;
  List<ModelFeed> listFeed = [];

  @override
  void initState() {
    _initializeBloc();
    loadData();
    _textEditingController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeBloc() {
    _bloc = context.read<FeedBloc>();
  }

  Future<void> loadData() async {
    isLoading = true;
    // print("haloooo $isLoading");
    await _bloc.add(GetFeedEvent(
      search: _textEditingController.text,
      offset: offset,
      limit: limit,
    ));
  }

  /// load more data attendance
  Future<void> _loadMoreData() async {
    if (hasNextPage == false) return;
    isLoadingMore = true;
    offset += limit;
    final moreData = await _bloc.add(GetFeedEvent(
      search: _textEditingController.text,
      offset: offset,
      limit: limit,
    ));

    listFeed.addAll(moreData);
    isLoadingMore = false;
  }

  /// on search changed listener
  void _onSearchChanged() async {
    isLoading = true;
    hasNextPage = true;
    listFeed.clear();
    offset = 0;
    attemptCount = 0;
    Future.delayed(
        const Duration(seconds: 5),
        _bloc.add(GetFeedEvent(
          search: _textEditingController.text.toLowerCase(),
          offset: offset,
          limit: limit,
        )));
  }

  /// refresh data
  refreshData() async {
    isLoading = true;
    listFeed.clear();
    offset = 0;
    attemptCount = 0;
    hasNextPage = true;
    _textEditingController.text;
    setState(() {});
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        hasNextPage) {
      _loadMoreData();
    }
  }

  /// handle listener presence
  handleListenerPrecense(BuildContext context, FeedState state) {
    if (state.status == RequestStatus.success && state.feedList.isNotEmpty) {
      listFeed.addAll(state.feedList);
      isLoading = false;

      attemptCount = 0;
    }

    if (state.feedList.isEmpty && state.status == RequestStatus.success) {
      isLoading = false;
      isLoadingMore = false;
      attemptCount++;
      if (attemptCount == maxAttempts) {
        hasNextPage = false;
        isLoadingMore = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Terkini'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.only(left: 10.5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: backgroundContainerColor),
                child: TextField(
                  controller: _textEditingController,
                  style: AppTypography.regular14,
                  decoration: InputDecoration(
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 20,
                        minWidth: 20,
                      ),
                      border: InputBorder.none,
                      hintStyle: AppTypography.regular14inActive,
                      hintText: 'Cari Berita',
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: SvgPicture.asset("assets/images/ic_search.svg",
                            width: 20, height: 20),
                      )),
                )),
            Expanded(
              child: BlocConsumer<FeedBloc, FeedState>(
                listener: (context, state) {
                  handleListenerPrecense(context, state);
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await refreshData();
                        loadData();
                      },
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          if (index < listFeed.length) {
                            return CardListAllFeed(
                              ontap: () {
                                AppRouter.router.push(
                                    PAGES.feeddetail.screenPath,
                                    extra: listFeed[index].id.toString());
                              },
                              images: listFeed[index].image ?? "",
                              title: listFeed[index].title ?? "",
                              date: listFeed[index].publishedAt ?? "",
                              // tagType: 'training',
                            );
                            // Tampilkan data
                          } else if (isLoading) {
                            return const ShimmerPlaceholderInvoiceList();
                          } else if (hasNextPage == true && isLoadingMore) {
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
                          } else if (listFeed.isEmpty &&
                              state.status == RequestStatus.success) {
                            return const Center(
                              child: CardFeedEmpty(
                                image: 'assets/images/img_list_empty.svg',
                                title: "Ups! Berita tidak ditemukan",
                                body:
                                    "Coba cari judul atau kata kunci yang lain, ya!",
                              ),
                            );
                          }
                          return null;
                        },

                        // CardListAllFeed(
                        //   ontap: () {
                        //     AppRouter.router.push(
                        //         PAGES.feeddetail.screenPath,
                        //         extra: listFeed[index].id.toString());
                        //   },
                        //   images: 'assets/images/default_list_feed.png',
                        //   title: 'Diklat Digital Marketing Berjenjang',
                        //   date: '13 Juni 2023',
                        //   tagType: 'training',
                        // );
                        // },
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: listFeed.length + 1,
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
