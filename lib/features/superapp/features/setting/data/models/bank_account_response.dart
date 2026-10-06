import '../../domain/entities/bank_account_entry.dart';

class BankAccountResponse {
  const BankAccountResponse(this.accounts);
  final List<BankAccountEntry> accounts;

  factory BankAccountResponse.fromJson(dynamic json) {
    final body = json is Map ? json['data'] : json;
    if (body is! List) {
      throw const FormatException('Daftar rekening tidak valid');
    }
    final list = body;
    return BankAccountResponse(list.whereType<Map>().map((item) {
      final data = Map<String, dynamic>.from(item);
      return BankAccountEntry(
        id: int.tryParse('${data['bank_account_id'] ?? ''}'),
        bankName: '${data['bank_name'] ?? ''}',
        accountName: '${data['account_name'] ?? ''}',
        accountNo: '${data['account_no'] ?? ''}',
      );
    }).toList());
  }
}

class AvailableBankResponse {
  const AvailableBankResponse(this.banks);
  final List<AvailableBank> banks;

  factory AvailableBankResponse.fromJson(dynamic json) {
    final body = json is Map ? json['data'] : json;
    if (body is! List) {
      throw const FormatException('Daftar bank tidak valid');
    }
    final list = body;
    return AvailableBankResponse(list
        .whereType<Map>()
        .map((item) {
          final data = Map<String, dynamic>.from(item);
          return AvailableBank(
            code: '${data['code'] ?? ''}',
            name: '${data['name'] ?? ''}',
          );
        })
        .where((bank) => bank.code.isNotEmpty && bank.name.isNotEmpty)
        .toList());
  }
}

class BankOwnerResponse {
  const BankOwnerResponse(this.accountName);
  final String? accountName;

  factory BankOwnerResponse.fromJson(dynamic json) {
    final body = json is Map && json.containsKey('data') ? json['data'] : json;
    if (body is! Map) return const BankOwnerResponse(null);
    final name = body['account_name']?.toString().trim();
    return BankOwnerResponse(name == null || name.isEmpty ? null : name);
  }
}

class BankOtpResponse {
  const BankOtpResponse(this.challenge);
  final BankOtpChallenge challenge;

  factory BankOtpResponse.fromJson(dynamic json) {
    final body = json is Map && json.containsKey('data') ? json['data'] : json;
    if (body is! Map) throw const FormatException('Respons OTP tidak valid');
    final token = body['token']?.toString() ?? '';
    final next = _parseDate(body['next_request_at']);
    if (token.isEmpty || next == null) {
      throw const FormatException(
          'Token atau waktu kirim ulang OTP tidak tersedia');
    }
    return BankOtpResponse(BankOtpChallenge(
      token: token,
      nextRequestAt: next,
      expiredAt: _parseDate(body['expired_at']),
    ));
  }

  static DateTime? _parseDate(dynamic value) => value == null
      ? null
      : DateTime.tryParse(value.toString().replaceFirst(' ', 'T'));
}
