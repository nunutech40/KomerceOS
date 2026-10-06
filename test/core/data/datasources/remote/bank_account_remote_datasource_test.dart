import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/features/superapp/features/setting/data/datasources/bank_account_remote_datasource.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/helpers.dart';

Response<dynamic> response(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
      data: data,
    );

void main() {
  late MockDioClient client;
  late BankAccountRemoteDataSourceImpl datasource;

  setUp(() {
    client = MockDioClient();
    datasource = BankAccountRemoteDataSourceImpl(client);
  });

  test('daftar rekening memakai endpoint Komship dan modelnya', () async {
    when(client.get(Endpoints.komshipBankAccounts))
        .thenAnswer((_) async => response({
              'status': 'success',
              'data': [
                {
                  'bank_account_id': 7,
                  'bank_name': 'BCA',
                  'account_name': 'Siti',
                  'account_no': '12345',
                }
              ],
            }));

    final result = await datasource.accounts();
    expect(result.accounts.single.id, 7);
    expect(result.accounts.single.accountName, 'Siti');
    verify(client.get(Endpoints.komshipBankAccounts)).called(1);
  });

  test('respons daftar rekening rusak tidak dianggap daftar kosong', () async {
    when(client.get(Endpoints.komshipBankAccounts))
        .thenAnswer((_) async => response({'status': 'success', 'data': null}));
    expect(datasource.accounts(), throwsA(isA<FormatException>()));
  });

  test('status gagal dari host Komship tidak dianggap berhasil', () async {
    when(client.get(Endpoints.komshipBankAccounts)).thenAnswer(
        (_) async => response({'status': 'failed', 'data': [], 'message': 'Gagal'}));

    expect(datasource.accounts(), throwsA(isA<ServerException>()));
  });

  test('request OTP rekening mengirim purpose dan metode, memakai deadline BE',
      () async {
    when(client.post(Endpoints.otpRequestPhone, data: {
      'purpose': 'rekening',
      'type_otp': 'whatsapp',
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {
            'token': 'token-otp',
            'expired_at': '2026-10-05 19:40:00',
            'next_request_at': '2026-10-05 19:32:00',
          }
        }));

    final challenge = (await datasource.requestOtp('whatsapp')).challenge;
    expect(challenge.token, 'token-otp');
    expect(challenge.nextRequestAt, DateTime(2026, 10, 5, 19, 32));
    verify(client.post(Endpoints.otpRequestPhone, data: {
      'purpose': 'rekening',
      'type_otp': 'whatsapp',
    })).called(1);
  });

  test('cek pemilik mengirim kode bank dan nomor rekening', () async {
    when(client.post(Endpoints.komshipCheckBankOwner, data: {
      'bank_name': 'BCA',
      'account_no': '12345',
    })).thenAnswer((_) async => response({
          'status': 'success',
          'data': {'account_name': 'Siti'},
        }));

    final owner = await datasource.owner('BCA', '12345');
    expect(owner.accountName, 'Siti');
    verify(client.post(Endpoints.komshipCheckBankOwner, data: {
      'bank_name': 'BCA',
      'account_no': '12345',
    })).called(1);
  });

  test('cek duplikat mengirim user ID dan form fields Komship', () async {
    when(client.post(Endpoints.komshipCheckBankAlready,
            options: anyNamed('options'), data: anyNamed('data')))
        .thenAnswer((_) async => response({'code': 200, 'data': {}}));

    await datasource.checkDuplicate('BCA', 'Siti', '12345', 42);

    final calls = verify(client.post(Endpoints.komshipCheckBankAlready,
            options: captureAnyNamed('options'), data: captureAnyNamed('data')))
        .captured;
    expect(
        (calls[0] as Options).contentType, Headers.formUrlEncodedContentType);
    expect(calls[1], {
      'bank_name': 'BCA',
      'account_name': 'Siti',
      'account_no': '12345',
      'user_id': 42,
    });
  });

  test('rekening duplikat menampilkan pesan BE tanpa membuka alur lain', () async {
    when(client.post(Endpoints.komshipCheckBankAlready,
            options: anyNamed('options'), data: anyNamed('data')))
        .thenAnswer((_) async => response({
              'status': 'error',
              'code': 1002,
              'message': 'Rekening sudah digunakan',
              'data': [],
            }));

    expect(
      datasource.checkDuplicate('BCA', 'Siti', '12345', 42),
      throwsA(isA<ServerException>().having(
          (error) => error.message, 'message', 'Rekening sudah digunakan')),
    );
  });

  test('pesan duplikat dari HTTP error tetap diteruskan', () async {
    when(client.post(Endpoints.komshipCheckBankAlready,
            options: anyNamed('options'), data: anyNamed('data')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: Endpoints.komshipCheckBankAlready),
      type: DioExceptionType.badResponse,
      response: response({
        'status': 'error',
        'code': 1002,
        'message': 'Rekening sudah digunakan',
      }),
    ));

    expect(
      datasource.checkDuplicate('BCA', 'Siti', '12345', 42),
      throwsA(isA<ServerException>().having(
          (error) => error.message, 'message', 'Rekening sudah digunakan')),
    );
  });

  test('OTP divalidasi sebelum simpan, token konteks rekening konsisten',
      () async {
    final secured = base64Encode(utf8.encode('token-otp%rekening'));
    when(client.post(Endpoints.otpVerify, data: {
      'otp': '123456',
      'token': secured,
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {'is_valid': true},
        }));
    when(client.post(Endpoints.securedAddBankAccount, data: {
      'token': secured,
      'bank_name': 'BCA',
      'account_no': '12345',
      'account_name': 'Siti',
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {},
        }));

    await datasource.verifyOtp('123456', 'token-otp');
    await datasource.addAccount('token-otp', 'BCA', '12345', 'Siti');

    verifyInOrder([
      client.post(Endpoints.otpVerify, data: {
        'otp': '123456',
        'token': secured,
      }),
      client.post(Endpoints.securedAddBankAccount, data: {
        'token': secured,
        'bank_name': 'BCA',
        'account_no': '12345',
        'account_name': 'Siti',
      }),
    ]);
  });

  test('OTP ditolak server tidak bisa dianggap terverifikasi', () async {
    final secured = base64Encode(utf8.encode('token-otp%rekening'));
    when(client.post(Endpoints.otpVerify, data: {
      'otp': '000000',
      'token': secured,
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {'is_valid': false},
        }));
    expect(datasource.verifyOtp('000000', 'token-otp'), throwsStateError);
  });
}
