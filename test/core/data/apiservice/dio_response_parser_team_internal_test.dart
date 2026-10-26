import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/exception.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';

void main() {
  test('mempertahankan kode Team Internal pada meta gagal HTTP 200', () {
    final response = Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: '/auth/check-login'),
      statusCode: 200,
      data: {
        'meta': {
          'status': 'failed',
          'code': 'ERR_ROLE_TEAM_INTERNAL_BLOCKED',
          'message': 'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
        },
        'data': null,
      },
    );

    expect(
      () => DioResponseParser().parseResponse<bool>(response, (_) => true),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'ERR_ROLE_TEAM_INTERNAL_BLOCKED: '
              'Akun Anda tidak memiliki akses untuk masuk ke aplikasi.',
        ),
      ),
    );
  });
}
