import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/core/data/apiservice/interceptors/safe_chucker_interceptor.dart';

void main() {
  test('redacts nested credentials without changing ordinary response data', () {
    final source = <String, dynamic>{
      'message': 'PIN salah',
      'data': {
        'access_token': 'secret-token',
        'refreshToken': 'secret-refresh',
        'pin': '123456',
        'pin_code': '123456',
        'otp_code': '654321',
        'account_name': 'John Doe',
      },
    };

    final safe = sanitizeChuckerPayload(source) as Map<String, dynamic>;
    final data = safe['data'] as Map<String, dynamic>;
    expect(safe['message'], 'PIN salah');
    expect(data['access_token'], '[REDACTED]');
    expect(data['refreshToken'], '[REDACTED]');
    expect(data['pin'], '[REDACTED]');
    expect(data['pin_code'], '[REDACTED]');
    expect(data['otp_code'], '[REDACTED]');
    expect(data['account_name'], 'John Doe');
    expect((source['data'] as Map)['pin'], '123456');
  });

  test('redacts credentials in JSON and multipart form bodies', () {
    final json = sanitizeChuckerPayload(
      '{"email":"test@example.com","password":"secret","token":"abc"}',
    ) as Map<String, dynamic>;
    expect(json['email'], 'test@example.com');
    expect(json['password'], '[REDACTED]');
    expect(json['token'], '[REDACTED]');

    final form = FormData.fromMap({
      'bank_name': 'BCA',
      'token': 'secret-token',
      'new_pin': '123456',
    });
    final safe = sanitizeChuckerPayload(form) as List<dynamic>;
    expect(safe[0], {'bank_name': 'BCA'});
    expect(safe[1], {'token': '[REDACTED]'});
    expect(safe[2], {'new_pin': '[REDACTED]'});
  });

  test('omits an unstructured raw body that cannot be redacted safely', () {
    expect(sanitizeChuckerPayload('plain secret text'),
        '[non-JSON body omitted]');
  });
}
