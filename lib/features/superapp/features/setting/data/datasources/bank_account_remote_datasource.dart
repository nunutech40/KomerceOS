import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import '../../domain/entities/bank_account_entry.dart';
import '../models/bank_account_response.dart';

abstract class BankAccountRemoteDataSource {
  Future<BankAccountResponse> accounts();
  Future<AvailableBankResponse> banks();
  Future<BankOwnerResponse> owner(String bankCode, String accountNo);
  Future<BankAccountCheckResult> checkDuplicate(
      String bankCode, String owner, String accountNo, int userId);
  Future<bool> whatsappAvailable(String phone);
  Future<BankOtpResponse> requestOtp(String method);
  Future<void> verifyOtp(String otp, String token);
  Future<void> addAccount(
      String token, String bankCode, String accountNo, String owner);
}

class BankAccountRemoteDataSourceImpl implements BankAccountRemoteDataSource {
  const BankAccountRemoteDataSourceImpl(this.client);
  final DioClient client;

  dynamic _data(Response response) {
    final body = response.data;
    if (body is! Map) throw const FormatException('Respons tidak valid');
    final meta = body['meta'];
    if (meta is Map && meta['status'] != 'success') {
      throw ServerException('${meta['message'] ?? 'Permintaan gagal'}');
    }
    if (body['status'] == false ||
        (body['status'] is String && body['status'] != 'success') ||
        (body['code'] is int && (body['code'] as int) >= 400)) {
      throw ServerException('${body['message'] ?? 'Permintaan gagal'}');
    }
    if (!body.containsKey('data') && meta == null && body['status'] == null) {
      throw const FormatException('Data respons tidak tersedia');
    }
    return body['data'];
  }

  @override
  Future<BankAccountResponse> accounts() async {
    final response = await client.get(Endpoints.komshipBankAccounts);
    return BankAccountResponse.fromJson(_data(response));
  }

  @override
  Future<AvailableBankResponse> banks() async {
    final response = await client.get(Endpoints.komshipAvailableBanks);
    return AvailableBankResponse.fromJson(_data(response));
  }

  @override
  Future<BankOwnerResponse> owner(String bankCode, String accountNo) async {
    final response = await client.post(Endpoints.komshipCheckBankOwner,
        data: {'bank_name': bankCode, 'account_no': accountNo});
    return BankOwnerResponse.fromJson(_data(response));
  }

  @override
  Future<BankAccountCheckResult> checkDuplicate(
      String bankCode, String owner, String accountNo, int userId) async {
    try {
      final response = await client.post(Endpoints.komshipCheckBankAlready,
          options: Options(contentType: Headers.formUrlEncodedContentType),
          data: {
            'bank_name': bankCode,
            'account_name': owner,
            'account_no': accountNo,
            'user_id': userId,
          });
      final body = response.data;
      if (body is Map && body['code'] == 1002) {
        return _liabilityResult(body);
      }
      _data(response);
      return const BankAccountCheckResult.clear();
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map && body['code'] == 1002) {
        return _liabilityResult(body);
      }
      if (body is Map &&
          body['message'] is String &&
          (body['message'] as String).trim().isNotEmpty) {
        throw ServerException(body['message'] as String);
      }
      rethrow;
    }
  }

  BankAccountCheckResult _liabilityResult(Map body) {
    final rows = body['data'];
    if (rows is! List || rows.isEmpty) {
      throw ServerException(
          '${body['message'] ?? 'Rincian tanggungan tidak tersedia'}');
    }
    final liabilities = rows.whereType<Map>().map((row) {
      final balance = int.tryParse('${row['saldo'] ?? ''}');
      if (balance == null || balance >= 0) {
        throw const FormatException('Saldo tanggungan tidak valid');
      }
      return BankLiability(
        email: '${row['email'] ?? ''}',
        balance: balance,
        userId: int.tryParse('${row['id'] ?? ''}'),
      );
    }).toList();
    if (liabilities.isEmpty) {
      throw const FormatException('Rincian tanggungan tidak tersedia');
    }
    return BankAccountCheckResult.liabilities(liabilities);
  }

  @override
  Future<bool> whatsappAvailable(String phone) async {
    if (phone.trim().isEmpty) return false;
    try {
      final response = await client.post(Endpoints.komshipCheckWhatsApp,
          queryParameters: {'phone_no': phone});
      final body = response.data;
      if (body is! Map) {
        throw const FormatException('Status WhatsApp tidak valid');
      }
      return body['status'] == 'success';
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) return false;
      rethrow;
    }
  }

  @override
  Future<BankOtpResponse> requestOtp(String method) async {
    final response = await client.post(Endpoints.otpRequestPhone, data: {
      'purpose': 'rekening',
      'type_otp': method,
    });
    return BankOtpResponse.fromJson(_data(response));
  }

  String _securedToken(String token) =>
      base64Encode(utf8.encode('$token%rekening'));

  @override
  Future<void> verifyOtp(String otp, String token) async {
    final response = await client.post(Endpoints.otpVerify,
        data: {'otp': otp, 'token': _securedToken(token)});
    final data = _data(response);
    if (data is Map && data['is_valid'] == false) {
      throw StateError('Kode OTP salah. Harap cek OTP, lalu coba lagi.');
    }
  }

  @override
  Future<void> addAccount(
      String token, String bankCode, String accountNo, String owner) async {
    final response = await client.post(Endpoints.securedAddBankAccount, data: {
      'token': _securedToken(token),
      'bank_name': bankCode,
      'account_no': accountNo,
      'account_name': owner,
    });
    _data(response);
  }
}
