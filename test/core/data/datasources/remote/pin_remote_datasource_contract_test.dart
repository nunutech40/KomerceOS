import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/datasources/remote/pin_remote_datasource.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/helpers.dart';

Response<dynamic> response(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
      data: data,
    );

void main() {
  late MockDioClient client;
  late PinRemoteDataSourceImpl datasource;

  setUp(() {
    client = MockDioClient();
    datasource = PinRemoteDataSourceImpl(
      client: client,
      responseParser: DioResponseParser(),
    );
  });

  test('status PIN Pengaturan memakai GET Komship tanpa query partner_id',
      () async {
    expect(Endpoints.checkPinSetting, Endpoints.checkPinExisting);
    when(client.get(Endpoints.checkPinExisting))
        .thenAnswer((_) async => response({
              'status': 'success',
              'code': 200,
              'data': {'is_set': true},
            }));

    expect((await datasource.checkPinSetting()).isExist, isTrue);
    expect((await datasource.checkPin()).isExist, isTrue);
    verify(client.get(Endpoints.checkPinExisting)).called(2);
  });

  test('respons cek PIN rusak tidak dianggap belum punya PIN', () async {
    when(client.get(Endpoints.checkPinExisting))
        .thenAnswer((_) async => response({'status': 'success', 'data': {}}));

    expect(datasource.checkPinSetting(), throwsA(isA<FormatException>()));
  });

  test('ubah PIN memakai usable token Komship dan PIN lama', () async {
    when(client.post(Endpoints.updatePinSetting, data: {
      'pin': '654321',
      'old_pin': '123456',
      'token': base64Encode(utf8.encode('usable-token')),
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {},
        }));

    expect(
        await datasource.changePin('654321', '123456', 'usable-token'), isTrue);
    verify(client.post(Endpoints.updatePinSetting, data: {
      'pin': '654321',
      'old_pin': '123456',
      'token': base64Encode(utf8.encode('usable-token')),
    })).called(1);
  });

  test('lupa PIN memakai token dengan konteks pin', () async {
    final token = base64Encode(utf8.encode('otp-token%pin'));
    when(client.post(Endpoints.otpVerify, data: {
      'otp': '123456',
      'token': token,
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {'attempt_left': 3},
        }));
    when(client.post(Endpoints.securedUpdatePin, data: {
      'new_pin': '654321',
      'token': token,
    })).thenAnswer((_) async => response({
          'meta': {'status': 'success'},
          'data': {},
        }));

    expect((await datasource.verifyOtp('123456', token: 'otp-token')).isValid,
        isTrue);
    expect(await datasource.updatePinSecured('654321', 'otp-token'), isTrue);
  });

  test('sisa percobaan diambil dari endpoint, bukan dihitung lokal', () async {
    when(client.get(Endpoints.pinAttemptLeft))
        .thenAnswer((_) async => response({
              'meta': {'status': 'success'},
              'data': {'attempt_left': 2},
            }));
    expect(await datasource.getAttemptLeft(), 2);
  });
}
