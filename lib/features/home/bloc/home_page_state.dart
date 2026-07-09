part of 'home_page_bloc.dart';

class HomePageState extends Equatable {
  const HomePageState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.statusCheckTopup = RequestStatus.empty,
    this.profileData,
    this.talentData,
    this.operation = '',
    this.pinData,
    this.topUpData,
    this.dataResponseCeckData,
    this.invoicesData = const [],
    this.shoppingList = const [],
    this.checkinvoice = false,
    this.feedList = const [],
    this.feedDetail,
    this.notificationCount,
    this.talentRecommendationData = const [],
  });

  final String message;
  final RequestStatus status;
  final RequestStatus statusCheckTopup;
  final ProfileModel? profileData;
  final TalentsModel? talentData;
  final String operation;
  final ChekPinModel? pinData;
  final TopupKompoinModel? topUpData;
  final TopupDetailResponse? dataResponseCeckData;
  final List<InvoicesDataModel> invoicesData;
  final List<ShoppingListDataModel> shoppingList;
  final bool checkinvoice;
  final List<ModelFeed> feedList;
  final ModelDetailFeed? feedDetail;
  final ModelFeedNotifCount? notificationCount;
  final List<TalentRecommendationModel>? talentRecommendationData;

  HomePageState copyWith({
    RequestStatus? status,
    RequestStatus? statusCheckTopup,
    String? message,
    ProfileModel? profileData,
    TalentsModel? talentData,
    String? operation,
    ChekPinModel? pinData,
    TopupKompoinModel? topUpData,
    List<TransactionHistoryDataModel>? transactionHistoryData,
    final TopupDetailResponse? dataResponseCeckData,
    List<InvoicesDataModel>? invoicesData,
    List<ShoppingListDataModel>? shoppingList,
    List<ModelFeed>? feedList,
    ModelDetailFeed? feedDetail,
    bool? checkinvoice,
    ModelFeedNotifCount? notificationCount,
    List<TalentRecommendationModel>? talentRecommendationData,
  }) {
    return HomePageState(
      status: status ?? this.status,
      statusCheckTopup: statusCheckTopup ?? this.statusCheckTopup,
      message: message ?? this.message,
      profileData: profileData ?? this.profileData,
      talentData: talentData ?? this.talentData,
      operation: operation ?? this.operation,
      pinData: pinData ?? this.pinData,
      topUpData: topUpData ?? this.topUpData,
      dataResponseCeckData: dataResponseCeckData ?? this.dataResponseCeckData,
      invoicesData: invoicesData ?? this.invoicesData,
      shoppingList: shoppingList ?? this.shoppingList,
      checkinvoice: checkinvoice ?? this.checkinvoice,
      feedList: feedList ?? this.feedList,
      feedDetail: feedDetail ?? this.feedDetail,
      notificationCount: notificationCount ?? this.notificationCount,
      talentRecommendationData:
          talentRecommendationData ?? this.talentRecommendationData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        statusCheckTopup,
        status,
        statusCheckTopup,
        profileData,
        talentData,
        operation,
        pinData,
        topUpData,
        invoicesData,
        shoppingList,
        checkinvoice,
        feedList,
        feedDetail,
        notificationCount,
        talentRecommendationData,
      ];
}
