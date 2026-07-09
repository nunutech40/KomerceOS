import 'package:equatable/equatable.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/data/models/topup_response.dart';

class TopupState extends Equatable {
  const TopupState(
      {this.message = '',
      this.status = RequestStatus.empty,
      this.dataTopUpBank,
      this.dataResponseCeckData,
      this.dataResponseDetail,
      this.dataResponseQris});

  final String message;
  final RequestStatus status;

  final TopupResponse? dataTopUpBank;
  final TopupDetailResponse? dataResponseCeckData;
  final TopupDetailResponse? dataResponseDetail;
  final TopupQRISResponse? dataResponseQris;

  TopupState copyWith(
      {String? message,
      RequestStatus? status,
      TopupResponse? dataTopUpBank,
      TopupDetailResponse? dataResponseCeckData,
      TopupDetailResponse? dataResponseDetail,
      TopupQRISResponse? dataResponseQris}) {
    return TopupState(
        message: message ?? this.message,
        status: status ?? this.status,
        dataTopUpBank: dataTopUpBank ?? this.dataTopUpBank,
        dataResponseCeckData: dataResponseCeckData ?? this.dataResponseCeckData,
        dataResponseDetail: dataResponseDetail ?? this.dataResponseDetail,
        dataResponseQris: dataResponseQris ?? this.dataResponseQris);
  }

  @override
  List<Object?> get props => [
        message,
        status,
        dataTopUpBank,
        dataResponseCeckData,
        dataResponseDetail,
        dataResponseQris
      ];
}
