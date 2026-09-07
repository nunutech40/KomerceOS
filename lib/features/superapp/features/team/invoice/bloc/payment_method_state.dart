part of 'payment_method_bloc.dart';

class PaymentMethodState extends Equatable {
  const PaymentMethodState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.operation = '',
      this.invoiceDetail,
      this.profileData,
      this.balanceData,
      this.detailTopup,
      this.pinData,
      this.checkBillData});

  final String message;
  final RequestStatus status;
  final String operation;
  final ProfileModel? profileData;
  final InvoiceDetailModel? invoiceDetail;
  final ChekPinModel? pinData;
  final DashboardBalanceDataModel? balanceData;
  final TopupDetailResponse? detailTopup;
  final CheckBillModel? checkBillData;

  PaymentMethodState copyWith(
      {RequestStatus? status,
      String? message,
      String? operation,
      InvoiceDetailModel? invoiceDetail,
      ProfileModel? profileData,
      DashboardBalanceDataModel? balanceData,
      TopupDetailResponse? detailTopup,
      ChekPinModel? pinData,
      CheckBillModel? checkBillData}) {
    return PaymentMethodState(
        status: status ?? this.status,
        message: message ?? this.message,
        operation: operation ?? this.operation,
        invoiceDetail: invoiceDetail ?? this.invoiceDetail,
        profileData: profileData ?? this.profileData,
        balanceData: balanceData ?? this.balanceData,
        detailTopup: detailTopup ?? this.detailTopup,
        pinData: pinData ?? this.pinData,
        checkBillData: checkBillData ?? this.checkBillData);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        operation,
        invoiceDetail,
        profileData,
        balanceData,
        detailTopup,
        pinData,
        checkBillData,
      ];
}
