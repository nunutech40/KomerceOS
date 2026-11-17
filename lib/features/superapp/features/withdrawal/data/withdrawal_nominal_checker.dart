import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';

/// Respons API validasi nominal yang juga digunakan form Withdrawal Komship.
class WithdrawalNominalCheck {
  const WithdrawalNominalCheck({
    required this.balance,
    required this.maximum,
    required this.ideal,
    this.potentialReturn,
    this.potentialIncome,
  });

  final int balance;
  final int maximum;
  final int ideal;
  final int? potentialReturn;
  final int? potentialIncome;

  factory WithdrawalNominalCheck.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('Data validasi penarikan tidak valid');
    }
    final balance = num.tryParse('${json['balance'] ?? ''}')?.toInt();
    final ideal = num.tryParse('${json['ideal_balance'] ?? 0}')?.toInt();
    final maximum =
        num.tryParse('${json['maximum_withdraw_nominal'] ?? ''}')?.toInt();
    if (balance == null || ideal == null) {
      throw const FormatException('Batas penarikan tidak tersedia');
    }
    return WithdrawalNominalCheck(
      balance: balance,
      maximum: (maximum ?? balance - ideal).clamp(0, balance),
      ideal: ideal,
      potentialReturn: num.tryParse('${json['potency_retur'] ?? ''}')?.toInt(),
      potentialIncome: num.tryParse('${json['potency_income'] ?? ''}')?.toInt(),
    );
  }
}

class WithdrawalNominalChecker {
  const WithdrawalNominalChecker(this.client);

  final DioClient client;

  Future<WithdrawalNominalCheck> check(int nominal) async {
    final response = await client.get(
      Endpoints.komshipCheckPossibleWithdraw,
      queryParameters: {'withdrawal_request_nominal': nominal},
    );
    final body = response.data;
    if (body is! Map) {
      throw const FormatException('Respons validasi penarikan tidak valid');
    }
    if (body['status'] == false ||
        (body['status'] is String && body['status'] != 'success') ||
        (body['code'] is int && (body['code'] as int) >= 400)) {
      throw StateError('${body['message'] ?? 'Validasi penarikan gagal'}');
    }
    return WithdrawalNominalCheck.fromJson(body['data']);
  }
}
