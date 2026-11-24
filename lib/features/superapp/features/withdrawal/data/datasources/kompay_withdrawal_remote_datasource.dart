import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';

import '../../domain/entities/kompay_withdrawal.dart';

/// Requests a Kompay withdrawal with the same body as Komship web
/// (`withdrawalRequest`: user_id, transaction_type, nominal, rekening_id,
/// notes).
class KompayWithdrawalRemoteDataSource {
  const KompayWithdrawalRemoteDataSource({required this.client});

  final DioClient client;

  Future<void> request({
    required int userId,
    required int nominal,
    required int bankAccountId,
  }) async {
    final Response<dynamic> response;
    try {
      response = await client.post(Endpoints.kompayWithdrawalRequest, data: {
        'user_id': userId,
        'transaction_type': 'withdraw_to_me',
        'nominal': nominal,
        'rekening_id': bankAccountId,
        'notes': '-',
      });
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const KompayWithdrawalQueued();
      }
      final message = messageOf(error.response?.data);
      if (message != null) throw KompayWithdrawalRejected(message);
      rethrow;
    }
    ensureSuccess(response.data);
  }

  static void ensureSuccess(dynamic body) {
    if (body is! Map) return;
    final meta = body['meta'];
    final status = meta is Map ? meta['status'] : body['status'];
    if (status == false || (status is String && status != 'success')) {
      throw KompayWithdrawalRejected(
          messageOf(body) ?? 'Penarikan belum dapat diproses.');
    }
  }

  static String? messageOf(dynamic body) {
    if (body is! Map) return null;
    final meta = body['meta'];
    final message = (meta is Map ? meta['message'] : null) ?? body['message'];
    final text = message?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
