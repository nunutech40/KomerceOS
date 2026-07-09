import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:komtim_partner/common/global/mixin/handling_error_page.dart';
import 'package:komtim_partner/common/global/widgets/custom_button.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button.dart';
import 'package:komtim_partner/common/global/widgets/custom_text_field.dart';
import 'package:komtim_partner/common/string.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/utils/loading/loading_overlay.dart';
import 'package:komtim_partner/config/config.dart';
import 'package:komtim_partner/core/domain/entities/feed_model.dart';
import 'package:komtim_partner/core/domain/entities/talent_recomendation_model.dart';
import 'package:komtim_partner/core/domain/entities/talents_model.dart';
import 'package:komtim_partner/features/feed/widget/card_feed.dart';
import 'package:komtim_partner/features/home/bloc/home_page_bloc.dart';
import 'package:komtim_partner/features/home/widget/card_feed_empty.dart';
import 'package:komtim_partner/features/home/widget/talent_pool_widget.dart';
import 'package:komtim_partner/features/update/widget/status_update.dart';
import 'package:komtim_partner/features/update/widget/update_complete.dart';
import 'package:komtim_partner/features/update/widget/update_request_bottom_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/enum_status.dart';
import '../../../common/global/router/app_router.dart';
import '../../../common/global/router/router_utils.dart';
import '../../../common/global/widgets/confirmation_dialog_payment_topup.dart';
import '../../../common/global/widgets/custom_small_icon_button.dart';
import '../../../common/global/widgets/small_icon_card.dart';
import '../../../common/global/widgets/small_icon_card_notif.dart';
import '../../../common/utils/currency_format.dart';
import '../../../core/domain/entities/profile_model.dart';
import '../../ratetalent/view/web_view_page.dart';
import '../widget/bouncing_icon.dart';
import '../widget/list_section_leader.dart';
import '../widget/list_section_talent.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ErrorHandlingMixin {
  final TextEditingController _currencyController = TextEditingController();
  int _cleanedValue = 0;
  var _bloc;
  bool _isScrolled = false;
  late ScrollController _scrollController;

  ProfileModel? _profileData;
  String? typeCheckTrasactionStatus;
  String? cekstatus;
  final ValueNotifier<bool> _wasActive = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier =
      ValueNotifier<String?>(null);
  TalentsModel? dataTalents;
  bool isUpdateAvailable = false;
  bool _showBeritaTerkini = false;
  String versiLocal = '';
  String availableVersionRemote = '';
  String versionRemote = '';
  String versionRemoteIos = '';

  // final pref = di.locator<SharedPref>();
  String? statusAccount = "";
  int kmPoint = 0;
  String checkStatusWithdraw = "";
  List<dynamic> listInvoices = [];
  List<dynamic> listBelanja = [];
  List<ModelFeed> listFeed = [];
  List<TalentRecommendationModel> listTalentRecomendation = [];
  //Withdrawal
  String checktransaction = "withdrawal";
  // ADD THIS FLAG TO PREVENT LOOPING
  bool _hasFetchedTalentRecommendation = false;

  bool _isSection1Loading = true;
  bool _isSection2Loading = true;
  bool _isSection3Loading = true;
  static String get _baseUrlTalentPool =>
      Config.instance.baseUrlWebUrlTalentPool;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });

    checkForUpdatesAvailable();
    _setupCurrencyControllerListener();
    _initializeBloc();
    _initializeData();
  }

  void _initializeData() {
    _loadSection1();
    _loadSection2();
    _loadSection3();
  }

  //Handle Check Account
  checkAccountOff(BuildContext context, HomePageState state) async {
    String checkProsesWithdraw = "withdrawal";
    //condition checktransaction

    if (state.statusCheckTopup == RequestStatus.success &&
        checkProsesWithdraw == 'withdrawal') {
      checkStatusWithdraw = "withdrawal proses";
    } else if (state.statusCheckTopup == RequestStatus.empty &&
        checkProsesWithdraw == 'withdrawal') {
      checkStatusWithdraw = "empty";

      if (listInvoices.isEmpty &&
          kmPoint < 1 &&
          checkStatusWithdraw == "empty" &&
          statusAccount == "off") {
        // print("logout disini");
        _bloc.add(const LogoutButtonPressedEvent());
      }
    } else {
      // print("dilaur jangkauan");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
      loadData();
      // print("App resumed - data refreshed");
    }
  }

  Future<void> checkForUpdates() async {
    if (Platform.isIOS) {
      final Uri uri =
          Uri.parse("https://apps.apple.com/id/app/komtim/id6473518650");
      launchUrl(uri);
    } else {
      InAppUpdate.checkForUpdate().then((updateInfo) {
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
              if (appUpdateResult == AppUpdateResult.success) {
                if (!mounted) return;

                Navigator.pop(context);
                bottomSheetUpdateSuccess(context);
              }
            });
          }
        }
      });
    }
  }

  Future<void> checkForUpdatesAvailable() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versiLocal = packageInfo.version;
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval:
          const Duration(hours: 1), //change to 12 hour when to prod
    ));

    await remoteConfig.fetchAndActivate();
    versionRemote = remoteConfig.getString('version');
    versionRemoteIos = remoteConfig.getString('versionIos');
    _showBeritaTerkini = remoteConfig.getBool('show_berita_terkini');
    if (Platform.isIOS) {
      availableVersionRemote = versionRemoteIos;
    } else {
      availableVersionRemote = versionRemote;
    }
    isRemoteGreater(availableVersionRemote, versiLocal);
  }

  Future<void> isRemoteGreater(String remote, String local) async {
    // debugPrint("remotenya ${remote}");
    // debugPrint("localnya ${local}");
    int versionA = int.parse(remote.replaceAll('.', ''));
    int versionB = int.parse(local.replaceAll('.', ''));

    if (versionA > versionB) {
      isUpdateAvailable = true;
    } else if (versionA == versionB) {
      isUpdateAvailable = false;
    } else {
      isUpdateAvailable = false;
    }

    setState(() {});
  }

  void _loadSection1() {
    if (mounted) setState(() => _isSection1Loading = true);
    _bloc.add(const GetNotificationCountEvent());
    _bloc.add(LoadDataCecktransactionTopUpEvent(
        typeCheckTrasaction: checktransaction));
    _bloc.add(
        const InvoviceListPageDidload(type: 'active', limit: 100, offset: 0));
    _bloc.add(const GetShoppingListEvent(
        offset: 0,
        limit: 100,
        status: "requested",
        startDate: "",
        endDate: "",
        keyword: ""));
    _bloc.add(const HomePageDidload());
  }

  void _loadSection2() {
    if (mounted) setState(() => _isSection2Loading = true);
    _bloc.add(const GetTalentResult());
  }

  void _loadSection3() {
    if (mounted) setState(() => _isSection3Loading = true);
    _bloc.add(const GetFeedEvent(
      search: '',
      offset: 0,
      limit: 10,
    ));
  }

  Future<void> loadData() async {
    _loadSection1();
    _loadSection2();
    _loadSection3();
  }

  void loadTalent() async {
    await _bloc.add(const GetTalentResult());
  }

  void _loadTalentRecommendationIfNeeded(HomePageState state) {
    if (!_hasFetchedTalentRecommendation &&
        state.profileData?.businessSectoreId != null &&
        state.profileData!.businessSectoreId! > 0) {
      _hasFetchedTalentRecommendation = true;
      _bloc.add(GetTalentRecommendationEvent(
        offset: 0,
        limit: 15,
        rating: "3,4,5",
        businessSector: state.profileData!.businessSectoreId.toString(),
      ));
    }
  }

  loadDataCeckTransaction(String typeCheckTrasaction) async {
    // Invoke Bloc event after initial frame is rendered
    typeCheckTrasactionStatus = typeCheckTrasaction;
    await _bloc.add(LoadDataCecktransactionTopUpEvent(
        typeCheckTrasaction: typeCheckTrasactionStatus ?? ""));
  }

  refreshData() async {
    listInvoices.clear();
    listBelanja.clear();
    listFeed.clear();
    listTalentRecomendation.clear();
    typeCheckTrasactionStatus = null;
    _hasFetchedTalentRecommendation = false;
    await _bloc.add(const RefreshDataEvent());
  }

  // Define the _handleRefresh method
  Future<void> _handleRefresh() async {
    await refreshData();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _initializeBloc() {
    _bloc = context.read<HomePageBloc>();
  }

  void _setupCurrencyControllerListener() {
    _currencyController.addListener(() {
      final inputValue = _currencyController.text;

      final cleanedValue = _cleanInputValue(inputValue);
      _cleanedValue = cleanedValue;

      if (_cleanedValue < 10000) {
        _errorMessageNotifier.value = Strings.label_nom_min_topup;
      } else {
        _errorMessageNotifier.value = null; // clear the error message
      }

      final validatedValue = _validateMaxValue(cleanedValue);
      final formattedValue = _formatValue(validatedValue);
      _updateControllerValue(formattedValue);
      _updateButtonActivationStatus(validatedValue);
    });
  }

  int _cleanInputValue(String inputValue) {
    // Hilangkan semua titik dari inputValue dan coba ubah menjadi bilangan bulat.
    // Jika gagal, kembalikan 0.
    return int.tryParse(inputValue.replaceAll(".", "")) ?? 0;
  }

  int _validateMaxValue(int value) {
    // Pastikan nilai yang diberikan tidak melebihi nilai maksimum yang diizinkan
    const maxAllowedValue = 5000000;
    return math.min(value, maxAllowedValue);
  }

  String _formatValue(int value) {
    // Ubah format nilai menjadi format mata uang tanpa simbol mata uang
    return CurrencyFormat.convertWithoutSymbol(value, 0);
  }

  void _updateControllerValue(String formattedValue) {
    // Jika nilai yang diformat berbeda dari nilai saat ini di _currencyController,
    // perbarui _currencyController dengan nilai yang benar
    if (formattedValue != _currencyController.text) {
      _currencyController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }
  }

  void _handleTopUpSuccess(BuildContext context, HomePageState state) {
    final transactionPaymentUrl = state.topUpData?.transactionPaymentUrl;

    if (transactionPaymentUrl != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WebViewPage(url: transactionPaymentUrl)));
      _currencyController.text = '';
    } else {
      // Handle the scenario when transactionPaymentUrl is null, e.g., show an error message

      // print('Error: transactionPaymentUrl is null.');
    }
  }

  void _updateButtonActivationStatus(int value) {
    // Periksa apakah nilai yang dimasukkan melebihi atau sama dengan 10000.
    // Jika ya, aktifkan tombol. Jika tidak, nonaktifkan.
    final isCurrencyValid = value >= 10000;
    _wasActive.value = isCurrencyValid;
  }

  void _onCardTap() {
    AppRouter.router.pushNamed(
      PAGES.invoiceList.screenName,
      queryParameters: {
        'statusAccount': statusAccount,
      },
    );
    // AppRouter.router.push(PAGES.invoiceList.screenPath);
  }

  void _onCartTap() {
    AppRouter.router.push(PAGES.shoppingListPage.screenPath);
  }

  void _onAttendanceTap() {
    AppRouter.router.push(PAGES.attendance.screenPath);
  }

  void _onReportPerformanceTap() {
    AppRouter.router.push(PAGES.reportperformance.screenPath);
  }

  void _showBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final desiredHeight = screenHeight - 143.0;

    final newDataTalents = (dataTalents?.talents ?? [])
        .where((e) => e.talentName != null)
        .map((e) => e.talentName!)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: desiredHeight,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Image.asset('assets/images/rectangle-close.png'),
                  ),
                ),
                ListSectionLeader(
                    title: Strings.label_lead_or_talent,
                    items: dataTalents?.talentLeaders ?? []),
                const SizedBox(
                  height: 12.0,
                ),
                ListSectionTalent(
                    title: Strings.label_talent, items: newDataTalents),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          _isScrolled ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Container(
        color: _isScrolled ? Colors.white : primaryColor,
        child: SafeArea(
          bottom: false,
          child: Scaffold(
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      _buildTopColoredContainer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: BlocConsumer<HomePageBloc, HomePageState>(
                          listener: _handleBlocStateChanges,
                          builder: (context, state) {
                            if (state.profileData != null) {
                              _profileData = state.profileData;
                              statusAccount = state.profileData?.accountStatus;
                              kmPoint = state.profileData?.kmPoin ?? 0;

                              _loadTalentRecommendationIfNeeded(state);

                              // Set talent data jika sudah berhasil di-load
                              if (state.status == RequestStatus.success &&
                                  state.operation == 'getTalents') {
                                dataTalents = state.talentData;
                              }
                            }

                            return _buildProfileState(state);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: isUpdateAvailable
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: StatusUpdate(
                        availableVersion: availableVersionRemote,
                        onClicked: () {
                          bottomSheetUpdateRequest(context, () {
                            checkForUpdates();
                          });
                        },
                      ),
                    )
                  : null),
        ),
      ),
    );
  }

  Widget _buildTopColoredContainer() {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
    );
  }

  void _handleBlocStateChanges(
      BuildContext context, HomePageState state) async {
    await _handleFeedStateChange(context, state);
    if (!context.mounted) return;

    await _handleNotifeStateChange(context, state);
    if (!context.mounted) return;

    await _handleTalentRecomendationStateChange(context, state);
    if (!context.mounted) return;

    if (state.status == RequestStatus.success) {
      switch (state.operation) {
        case 'topUp':
          // Dismiss the bottom sheet
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          _handleTopUpSuccess(context, state);
          break;
        default:
          break;
      }
    } else if (state.status == RequestStatus.failure) {
      handleFailureState(context, state, state.message);
    }

    // Auth/session cleanup is handled by AuthenticationManager via DoLogoutUseCase.
  }

  _handleNotifeStateChange(BuildContext context, HomePageState state) async {
    if (state.invoicesData.isNotEmpty && listInvoices.isEmpty) {
      listInvoices.addAll(state.invoicesData);
    } else if (state.checkinvoice && state.invoicesData.isEmpty) {
      await checkAccountOff(context, state);
    }
    if (state.shoppingList.isNotEmpty && listBelanja.isEmpty) {
      listBelanja.addAll(state.shoppingList);
    }
  }

  _handleFeedStateChange(BuildContext context, HomePageState state) {
    if (state.feedList.isNotEmpty && listFeed.isEmpty) {
      listFeed.addAll(state.feedList);
      if (mounted && _isSection3Loading) {
        setState(() => _isSection3Loading = false);
      }
    } else if (state.operation == 'feedList' &&
        state.status != RequestStatus.loading) {
      if (mounted && _isSection3Loading) {
        setState(() => _isSection3Loading = false);
      }
    }
  }

  _handleTalentRecomendationStateChange(
      BuildContext context, HomePageState state) async {
    // Safe check for talent recommendation data
    if (state.talentRecommendationData != null &&
        state.talentRecommendationData!.isNotEmpty) {
      // Check if local list is null or empty before adding data
      if (listTalentRecomendation.isEmpty) {
        listTalentRecomendation.addAll(state.talentRecommendationData!);
        if (mounted) setState(() => _isSection2Loading = false);
      }
    } else if (state.status != RequestStatus.loading &&
        state.operation != 'getTalentRecommendation' &&
        !_hasFetchedTalentRecommendation) {
      // ADD FLAG CHECK HERE
      // Periksa apakah businessSectoreId valid sebelum memanggil event
      final businessSectorId = state.profileData?.businessSectoreId;

      // Hanya panggil GetTalentRecommendationEvent jika businessSectorId tidak null dan tidak 0
      if (businessSectorId != null && businessSectorId != 0) {
        _hasFetchedTalentRecommendation =
            true; // SET FLAG TO TRUE BEFORE CALLING
        await _bloc.add(GetTalentRecommendationEvent(
          offset: 0,
          limit: 15,
          rating: "2,4,5",
          businessSector: businessSectorId.toString(),
        ));
      } else if (state.profileData != null) {
        debugPrint(
            "Business sector ID is null or 0, skipping talent recommendation request");
        if (mounted && _isSection2Loading) {
          setState(() => _isSection2Loading = false);
        }
      }
    } else if (state.operation == 'getTalentRecommendation' &&
        state.status != RequestStatus.loading) {
      if (mounted && _isSection2Loading) {
        setState(() => _isSection2Loading = false);
      }
    }
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _ProfileInfoPlaceholder(),
          _SaldoKompayCardPlaceholder(),
          _InvoiceSectionPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildSection2Loading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 240, height: 12, color: Colors.white),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    children: [
                      Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                          )),
                      const SizedBox(height: 8),
                      Container(width: 60, height: 10, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 50, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection3Loading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 120, height: 16, color: Colors.white),
                Container(width: 80, height: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 160,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          )),
                      const SizedBox(height: 8),
                      Container(width: 140, height: 12, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 100, height: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileState(HomePageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isSection1Loading && state.profileData == null)
          _buildLoadingState()
        else ...[
          _ProfileInfo(state, context),
          _SaldoKompayCard(state, context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _InvoiceSection(_onCardTap, state)),
              Expanded(child: _ShoppingSection(_onCartTap, state)),
              Expanded(child: _AttendanceSection(_onAttendanceTap)),
              Expanded(
                  child: _ReportPerformanceSection(_onReportPerformanceTap)),
            ],
          ),
        ],
        if (_isSection2Loading && listTalentRecomendation.isEmpty)
          _buildSection2Loading()
        else
          talentPoolWidget(),
        if (_showBeritaTerkini)
          _isSection3Loading && listFeed.isEmpty
              ? _buildSection3Loading()
              : feedCard(),
      ],
    );
  }

  Widget talentPoolWidget() {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rekomendasi Talent untuk Bisnismu",
              style: AppTypography.regular14
                  .copyWith(color: blackColors33, fontWeight: FontWeight.w700),
            ),
            Text(
              "Kamu mungkin cocok dengan talent berikut ini!",
              style: AppTypography.regular12
                  .copyWith(color: blackColors33, fontWeight: FontWeight.w400),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15),
              width: MediaQuery.of(context).size.width,
              child: listTalentRecomendation.isEmpty
                  ? const Center(
                      child: CardFeedEmpty(
                        image: 'assets/images/ic_feed_empty.svg',
                        title: "Talent Recomendation",
                        body: "Tidak ada talent yang ditemukan",
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            listTalentRecomendation.take(15).length, (index) {
                          return Center(
                            child: TalentPoolWidget(
                              name: listTalentRecomendation[index].fullName,
                              profileImageUrl:
                                  listTalentRecomendation[index].photoUrl,
                              role: listTalentRecomendation[index].skillName,
                              heartCount:
                                  listTalentRecomendation[index].wishlistCount,
                              onTap: () async {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final url = Uri.parse(
                                    '$_baseUrlTalentPool/${listTalentRecomendation[index].id}');

                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  // Bisa tampilkan snackbar atau log error
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Tidak dapat membuka URL')),
                                  );
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
            ),
          ],
        ));
  }

  Widget feedCard() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Berita Terkini",
                style: AppTypography.regular14.copyWith(
                    color: blackColors33, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () {
                  AppRouter.router.push(
                    PAGES.feed.screenPath,
                  );
                },
                child: Text(
                  "Selengkapnya",
                  style: AppTypography.regular14.copyWith(
                      color: primaryColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 15),
            width: MediaQuery.of(context).size.width,
            child: listFeed.isEmpty
                ? const Center(
                    child: CardFeedEmpty(
                      image: 'assets/images/ic_feed_empty.svg',
                      title: "Belum ada berita apa pun",
                      body: "Tunggu update terbaru kami, ya!",
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(listFeed.take(3).length, (index) {
                        return Center(
                            child: CardFeed(
                                ontap: () {
                                  AppRouter.router.push(
                                      PAGES.feeddetail.screenPath,
                                      extra: listFeed[index].id.toString());
                                },
                                images: listFeed[index].image ?? "",
                                tagTalent: listFeed[index].visibility ?? "",
                                title: listFeed[index].title ?? "",
                                date: listFeed[index].publishedAt ?? "",
                                // tagType: 'training',
                                nametalent: listFeed[index].participants));
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

// Define your placeholder widgets here for each section, similar to what you did with the '_buildShimmeringUI'
  Widget _ProfileInfoPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // Assume average name width is around 100. Adjust based on your needs.
                width: 100,
                height: 16, // height of the Text widget
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Container(
                    width: 90, // approximate width for 'Leader Talent'
                    height: 20, // height of the Text widget
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 24, // width of the icon
                    height: 24, // height of the icon
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 24.0, // width of the image
            height: 24.0, // height of the image
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _SaldoKompayCardPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Card(
        elevation: 3.0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300], // A placeholder color
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 90, // width approximation for 'Saldo Kompay'
                    height: 16, // height approximation for the Text widget
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 110, // width approximation for currency value
                    height: 20, // height approximation for the Text widget
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40, // height approximation for the button
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Container(
                          height: 40, // height approximation for the button
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _InvoiceSectionPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              // Assuming there's a title in _InvoiceSection
              Container(
                width:
                    constraints.maxWidth * 0.5, // 50% of parent width for title
                height: 20,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8.0),
              // Placeholder for description or some other text
              Container(
                width: constraints.maxWidth * 0.8, // 80% of parent width
                height: 16,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: constraints.maxWidth * 0.6, // 60% of parent width
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: constraints.maxWidth * 0.3, // 30% of parent width
                    height: 20,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              // Add more placeholders here as per the structure of _InvoiceSection
            ],
          );
        },
      ),
    );
  }

  Widget _ProfileInfo(HomePageState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                state.profileData?.fullname.toString() ?? '',
                style: AppTypography.regular12.copyWith(color: Colors.white),
              ),
              if (dataTalents != null && dataTalents!.talents != null)
                Row(
                  children: [
                    Text(
                      Strings.label_lead_talent,
                      style: AppTypography.semiBold16
                          .copyWith(color: Colors.white),
                    ),
                    BouncingIcon(
                      onTap: () {
                        if (state.status == RequestStatus.success) {
                          _showBottomSheet(context);
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
          InkWell(
            onTap: () {
              AppRouter.router.push(
                PAGES.notification.screenPath,
                extra: statusAccount,
              );
            },
            child: Container(
              height: 48.0,
              width: 100,
              color: Colors.transparent,
              child: Stack(children: [
                Align(
                  alignment: Alignment
                      .topRight, // Aligns the child to the top-left of the container
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/images/ic-notif.svg',
                      height: 24.0,
                      width: 24.0,
                    ),
                  ),
                ),
                state.notificationCount != null &&
                        state.notificationCount?.count != null &&
                        state.notificationCount!.count! >= 0
                    ? Align(
                        alignment: Alignment
                            .topRight, // Aligns the child to the top-left of the container
                        child: Container(
                          width: 15,
                          height: 15,
                          margin: const EdgeInsets.only(right: 2, top: 4),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: orangeColor),
                          child: Center(
                            child: Text(
                              state.notificationCount!.count! >= 99
                                  ? "99"
                                  : state.notificationCount?.count.toString() ??
                                      "",
                              style: AppTypography.small14White,
                            ),
                          ),
                        ),
                      )
                    : Container()
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _SaldoKompayCard(HomePageState state, BuildContext context) {
    return BlocConsumer<HomePageBloc, HomePageState>(
        listener: (context, state) {
      if (state.statusCheckTopup == RequestStatus.success &&
          state.dataResponseCeckData?.transactionTopupType == "bank_transfer" &&
          state.dataResponseCeckData?.transactionType == "topup" &&
          typeCheckTrasactionStatus == 'topup') {
        showInformationPayment(
            context,
            state.dataResponseCeckData?.transactionId.toString() ?? "",
            state.dataResponseCeckData?.transactionTopupType);
      } else if (state.statusCheckTopup == RequestStatus.success &&
          state.dataResponseCeckData?.transactionTopupType == "qris" &&
          state.dataResponseCeckData?.transactionType == "topup" &&
          typeCheckTrasactionStatus == 'topup') {
        showInformationPayment(
            context,
            state.dataResponseCeckData?.transactionId.toString() ?? "",
            state.dataResponseCeckData?.transactionTopupType);
      } else if (state.statusCheckTopup == RequestStatus.success &&
          typeCheckTrasactionStatus == "withdrawal") {
        showInformationPayment(
            context,
            state.dataResponseCeckData?.transactionId.toString() ?? "",
            state.dataResponseCeckData?.transactionType);
      } else if (state.statusCheckTopup == RequestStatus.empty &&
          typeCheckTrasactionStatus == 'topup') {
        AppRouter.router.pushNamed(
          PAGES.topuppages.screenName,
        );
      } else if (state.statusCheckTopup == RequestStatus.empty &&
          typeCheckTrasactionStatus == 'withdrawal') {
        AppRouter.router
            .pushNamed(PAGES.withdrawKompoyPage.screenName, queryParameters: {
          'saldoKompay': [(_profileData?.kmPoin ?? 0).toString()]
        });
      } else if (state.status == RequestStatus.failure) {
        handleFailureState(context, state, state.message);
      }
    }, builder: (context, state) {
      return Container(
        margin: const EdgeInsets.only(top: 16.0),
        child: Card(
          elevation: 3.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffff8f8f8),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      Strings.label_kompay_balance,
                      style: AppTypography.regular12,
                    ),
                    Text(
                      CurrencyFormat.convertToIdrWithSpasi(
                          _profileData?.kmPoin ?? 0, 0),
                      style: AppTypographyCustom(fontSize: 20.0).semiBoldCustom,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_kompoint.svg',
                          width: 18.0,
                          height: 18.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _profileData?.kompoin.toString() ?? '0',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        const Text(
                          'KomPoint',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButtonSmallIcon(
                            text: 'Top up',
                            onPressed: () async {
                              loadDataCeckTransaction('topup');
                            },
                            txColor: Colors.white,
                            bgColor: primaryColor,
                            iconAsset: 'assets/images/ic-card-send.svg',
                            isActive: statusAccount == "off" ? false : true,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: CustomButtonSmallIcon(
                            text: Strings.label_withdraw,
                            onPressed: () async {
                              await loadDataCeckTransaction('withdrawal');
                            },
                            iconAsset: 'assets/images/ic-card-receive.svg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _InvoiceSection(VoidCallback onCardTap, HomePageState state) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              listInvoices.isNotEmpty
                  ? SmallIconCardNotife(
                      text: Strings.label_invoice,
                      iconAsset: 'assets/images/ic_invoice.svg',
                      textNotif: listInvoices.length >= 100
                          ? "99+"
                          : "${listInvoices.length}",
                      onTap: onCardTap,
                    )
                  : SmallIconCard(
                      text: Strings.label_invoice,
                      iconAsset: 'assets/images/ic_invoice.svg',
                      onTap: onCardTap,
                    )
            ],
          ),
        ],
      ),
    );
  }

  Widget _ShoppingSection(VoidCallback onCardTap, state) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              listBelanja.isNotEmpty
                  ? SmallIconCardNotife(
                      text: Strings.label_shopping,
                      iconAsset: 'assets/images/ic_cart.svg',
                      textNotif: listBelanja.length >= 100
                          ? "99+"
                          : "${listBelanja.length}",
                      onTap: onCardTap,
                      isActive: statusAccount == "off" ? false : true,
                    )
                  : SmallIconCard(
                      text: Strings.label_shopping,
                      iconAsset: 'assets/images/ic_cart.svg',
                      onTap: onCardTap,
                      isActive: statusAccount == "off" ? false : true,
                    )
            ],
          ),
        ],
      ),
    );
  }

  Widget _AttendanceSection(VoidCallback onCardTap) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SmallIconCard(
                text: 'Presensi',
                iconAsset: 'assets/images/ic_presence.svg',
                onTap: onCardTap,
                isActive: statusAccount == "off" ? false : true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ReportPerformanceSection(VoidCallback onCardTap) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SmallIconCard(
                text: 'Report Performa',
                iconAsset: 'assets/images/ic_report_performance.svg',
                onTap: onCardTap,
                isActive: statusAccount == "off" ? false : true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget shimmerPlaceholder({required double width, required double height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: width * 0.6, // 60% of the passed width
            height: height,
            color: Colors.white,
          ),
          Container(
            width: width * 0.3, // 30% of the passed width
            height: height,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  showInformationPayment(
      BuildContext context, String? idTrancaction, String? typePayment) {
    typeCheckTrasactionStatus = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialogNeedProsessPaymentTopUp(
            idTrancaction: idTrancaction, typePayment: typePayment);
      },
    );
  }
}

class BSTopupSaldo extends StatelessWidget {
  final ValueNotifier<bool> buttonActiveNotifier;
  final ValueNotifier<String?> errorMessageNotifier;
  final TextEditingController currencyController;
  final VoidCallback onCancel;
  final VoidCallback onTopUp;
  final bool isLoading;

  const BSTopupSaldo(
      {Key? key,
      required this.buttonActiveNotifier,
      required this.errorMessageNotifier,
      required this.currencyController,
      required this.onCancel,
      required this.onTopUp,
      this.isLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/images/rectangle-close.png'),
                  ),
                  const SizedBox(height: 14.0),
                  const Text(Strings.label_topup,
                      style: AppTypography.semiBold14),
                  const SizedBox(height: 25.0),
                  const Text(Strings.label_nominal,
                      style: AppTypography.regular12),
                  const SizedBox(height: 5.0),
                  ValueListenableBuilder<String?>(
                    valueListenable: errorMessageNotifier,
                    builder: (context, errorMessage, child) {
                      return CustomTextField(
                        label: '',
                        hint: 'contoh:500.000',
                        onlyNumbers: true,
                        controller: currencyController,
                        errorText: errorMessage,
                      );
                    },
                  ),
                  const SizedBox(height: 110.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: CustomOutlineButton(
                            text: Strings.label_cancel,
                            onPressed: onCancel,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: buttonActiveNotifier,
                            builder: (context, isActive, child) {
                              return CustomButton(
                                text: Strings.label_topup,
                                onPressed: onTopUp,
                                isActive: isActive,
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) const LoadingOverlay(),
      ],
    );
  }
}
