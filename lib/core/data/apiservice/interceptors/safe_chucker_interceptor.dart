import 'dart:convert';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';

const _redacted = '[REDACTED]';

/// Keeps the actual HTTP exchange untouched while giving Chucker a redacted
/// copy. Chucker persists captured traffic on the QA device.
class SafeChuckerInterceptor extends Interceptor {
  // Chucker keeps requestTime on the interceptor instance. A separate capture
  // per request prevents parallel Home/Profile calls overwriting that time.
  final _captures = Expando<ChuckerDioInterceptor>();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final capture = ChuckerDioInterceptor();
    _captures[options] = capture;
    try {
      await capture.onRequest(
          _redactedOptions(options), _ChuckerRequestHandler());
    } catch (_) {
      // Capture initialization must not fail a real request.
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    try {
      final capture = _captures[response.requestOptions];
      await capture?.onResponse(
        _redactedResponse(response),
        _ChuckerResponseHandler(),
      );
    } catch (_) {
      // Diagnostics must not turn a successful API call into a failure.
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      final safeOptions = _redactedOptions(err.requestOptions);
      final diagnostics = err.response == null
          ? Response<dynamic>(
              requestOptions: safeOptions,
              data: {
                'client_transport_error': {
                  'type': err.type.name,
                  'cause': err.error.runtimeType.toString(),
                  if (err.error is SocketException)
                    'os_error_code':
                        (err.error as SocketException).osError?.errorCode,
                  'has_http_response': false,
                },
              },
            )
          : _redactedResponse(err.response!, options: safeOptions);
      final capture = _captures[err.requestOptions];
      await capture?.onError(
        err.copyWith(
          requestOptions: safeOptions,
          // This copy only feeds Chucker. A missing HTTP response stays -1,
          // with explicit client diagnostics instead of an empty body.
          response: diagnostics,
        ),
        _ChuckerErrorHandler(),
      );
    } catch (_) {
      // Diagnostics must not replace the original API error.
    }
    handler.next(err);
  }
}

class _ChuckerRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions options) {}
}

class _ChuckerResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}
}

class _ChuckerErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException error) {}
}

Response<dynamic> _redactedResponse(Response<dynamic> response,
    {RequestOptions? options}) {
  final safeOptions = options ?? _redactedOptions(response.requestOptions);
  return Response<dynamic>(
    requestOptions: safeOptions,
    data: sanitizeChuckerPayload(response.data),
    statusCode: response.statusCode,
    statusMessage: response.statusMessage,
    headers: Headers.fromMap({
      for (final entry in response.headers.map.entries)
        entry.key: _isSensitiveKey(entry.key) ? [_redacted] : entry.value,
    }),
  );
}

RequestOptions _redactedOptions(RequestOptions options) => options.copyWith(
      path: _redactedPath(options.path),
      headers: sanitizeChuckerPayload(options.headers) as Map<String, dynamic>,
      queryParameters: sanitizeChuckerPayload(options.queryParameters)
          as Map<String, dynamic>,
      data: sanitizeChuckerPayload(options.data),
    );

String _redactedPath(String path) {
  if (!path.contains('?')) return path;
  final uri = Uri.tryParse(path);
  if (uri == null) return path.split('?').first;
  return uri.replace(queryParameters: {
    for (final entry in uri.queryParameters.entries)
      entry.key: _isSensitiveKey(entry.key) ? _redacted : entry.value,
  }).toString();
}

bool _isSensitiveKey(String key) {
  final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return normalized.contains('authorization') ||
      normalized.contains('cookie') ||
      normalized.contains('password') ||
      normalized.contains('token') ||
      normalized.contains('secret') ||
      normalized.contains('otp') ||
      normalized.startsWith('pin') ||
      normalized.endsWith('pin') ||
      normalized == 'pass' ||
      normalized.endsWith('passwd') ||
      normalized == 'code' ||
      normalized.endsWith('verificationcode');
}

/// Redact credentials recursively, including JSON strings and multipart form
/// fields, without mutating the values sent to the server.
dynamic sanitizeChuckerPayload(dynamic value) {
  return _sanitizePayload(value, rawString: true);
}

dynamic _sanitizePayload(dynamic value, {required bool rawString}) {
  if (value == null) return null;
  if (value is FormData) {
    return [
      for (final field in value.fields)
        {
          field.key: _isSensitiveKey(field.key)
              ? _redacted
              : _sanitizePayload(field.value, rawString: false),
        },
      for (final file in value.files) {file.key: '[file]'},
    ];
  }
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _isSensitiveKey(entry.key.toString())
            ? _redacted
            : _sanitizePayload(entry.value, rawString: false),
    };
  }
  if (value is List) {
    return value
        .map((item) => _sanitizePayload(item, rawString: false))
        .toList();
  }
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map || decoded is List) {
        return _sanitizePayload(decoded, rawString: false);
      }
    } catch (_) {
      // Non-JSON bodies may contain raw credentials.
    }
    return rawString ? '[non-JSON body omitted]' : value;
  }
  if (value is num || value is bool) return value;
  return '[unsupported body omitted]';
}
