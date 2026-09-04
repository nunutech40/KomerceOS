import 'package:dio/dio.dart';

import '../models/meta_response.dart';

class DioResponseParser {
  /// Parses the Dio response.
  /// Checks for 'meta' status if present.
  /// returns [T] using [fromJson].
  T parseResponse<T>(Response response, T Function(dynamic data) fromJson) {
    final dynamic responseBody = response.data;

    if (responseBody is Map<String, dynamic>) {
      final meta = responseBody['meta'];

      // Check if meta exists and status is success
      if (meta != null) {
        // Some APIs might return success for 200 but meta says error?
        // Usually 200 means success.

        if (meta['status'] == 'success') {
          final data = responseBody['data'];
          // If expecting a list but data is null, return empty list (handled by fromJson usually or wrapper)
          // But here we just pass data.
          return fromJson(data);
        } else {
          // Throw exception with message from meta
          final metaResponse = MetaResponse.fromJson(meta);
          String errorMessage = metaResponse.message ?? 'Unknown Error';
          
          final data = responseBody['data'];
          if (data is Map<String, dynamic>) {
            if (data.containsKey('login_attempt')) {
              errorMessage += ' login_attempt: ${data['login_attempt']}';
            }
            if (data.containsKey('lock')) {
              errorMessage += ' lock: ${data['lock']}';
            }
            if (data.containsKey('attempt_left')) {
              errorMessage += ' Sisa percobaan: ${data['attempt_left']}';
            }
          }
          
          throw Exception(errorMessage);
        }
      }
    }

    // Fallback: if no confirmed meta structure, try to parse 'data' or the body itself
    if (responseBody is Map<String, dynamic> &&
        responseBody.containsKey('data')) {
      return fromJson(responseBody['data']);
    }

    return fromJson(responseBody);
  }

  T parseResponseMetaData<T>(
      Response response, T Function(dynamic data) fromJson) {
    final dynamic responseBody = response.data;
    if (responseBody is Map<String, dynamic>) {
      final meta = responseBody['meta'];
      if (meta != null && meta['status'] != 'success') {
        final metaResponse = MetaResponse.fromJson(meta);
        throw Exception(metaResponse.message);
      }
    }
    return fromJson(responseBody);
  }

  // Parser specifically for meta responses (boolean check)
  Future<T> parseResponseMeta<T>(
    Response response,
    T Function(bool metaResponse) successHandler,
  ) async {
    final dynamic responseBody = response.data;
    if (responseBody is Map<String, dynamic>) {
      final meta = responseBody['meta'];
      if (meta != null) {
        if (meta['status'] == 'success') {
          return successHandler(true);
        } else {
          final metaResponse = MetaResponse.fromJson(meta);
          throw Exception(metaResponse.message);
        }
      }
    }
    // Fallback if no meta field or check not strict, return success true
    return successHandler(true);
  }
}
