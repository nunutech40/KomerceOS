part of 'history_page_bloc.dart';

class HistoryPageState extends Equatable {
  const HistoryPageState({
    this.message = '',
    this.status = RequestStatus.empty,
    this.statusDetail = RequestStatus.empty,
    this.operation = '',
    this.transactionHistoryData = const [],
    this.transactionNeedHistoryHistoryData = const [],
    this.dataResponseDetail,
    this.profileData,
  });

  final String message;
  final RequestStatus status;
  final RequestStatus statusDetail;
  final String operation;
  final List<TransactionHistoryDataModel> transactionHistoryData;
  final List<TransactionHistoryDataModel> transactionNeedHistoryHistoryData;
  final TopupDetailResponse? dataResponseDetail;
  final ProfileModel? profileData;

  HistoryPageState copyWith({
    RequestStatus? status,
    RequestStatus? statusDetail,
    String? message,
    TalentsModel? talentData,
    String? operation,
    TopupKompoinModel? topUpData,
    List<TransactionHistoryDataModel>? transactionHistoryData,
    List<TransactionHistoryDataModel>? transactionNeedHistoryHistoryData,
    final TopupDetailResponse? dataResponseDetail,
    ProfileModel? profileData,
  }) {
    return HistoryPageState(
      status: status ?? this.status,
      message: message ?? this.message,
      operation: operation ?? this.operation,
      transactionHistoryData:
          transactionHistoryData ?? this.transactionHistoryData,
      transactionNeedHistoryHistoryData: transactionNeedHistoryHistoryData ??
          this.transactionNeedHistoryHistoryData,
      dataResponseDetail: dataResponseDetail ?? this.dataResponseDetail,
      statusDetail: statusDetail ?? this.statusDetail,
      profileData: profileData ?? this.profileData,
    );
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
        transactionHistoryData,
        transactionNeedHistoryHistoryData,
        dataResponseDetail,
        statusDetail,
        profileData
      ];
}
