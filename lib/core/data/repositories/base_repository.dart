import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:komtim_partner/common/failure.dart';

import '../../../common/exception.dart';

abstract class BaseRepository {
  Future<Either<Failure, T>> executeEither<T>(Future<T> Function() f) async {
    try {
      final result = await f();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on SocketException catch (e) {
      return Left(
          ConnectionFailure('Failed to connect to the network: ${e.message}'));
    } on TimeoutException {
      return const Left(ConnectionFailure('Request timeout'));
    } catch (e) {
      return Left(UnknownFailure('Unexpected Error: ${e.toString()}'));
    }
  }

  Failure _handleDioError(DioException e) {
    // Connection-related errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ConnectionFailure('Request timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
          'Koneksi gagal. Periksa jaringan, lalu coba lagi.');
    }

    if (e.type == DioExceptionType.unknown && e.response == null) {
      // Chucker reports these transport failures as HTTP -1. There is no
      // server response or business error to display; keep the flow retryable.
      return const ConnectionFailure(
          'Tidak ada respons dari server. Periksa koneksi, lalu coba lagi.');
    }

    // Bad response (4xx, 5xx) — extract meta message from response body
    if (e.type == DioExceptionType.badResponse && e.response != null) {
      final responseData = e.response!.data;
      final statusCode = e.response!.statusCode ?? 0;

      if (responseData is Map<String, dynamic>) {
        // Some auth endpoints use a flat error envelope instead of `meta`.
        // Keep its domain code so the UI can select the access-denied popup.
        if (responseData['status'] == false &&
            responseData['error_code'] == 'ERR_ROLE_TEAM_INTERNAL_BLOCKED') {
          final message = responseData['message']?.toString().trim();
          return ServerFailure(
            'ERR_ROLE_TEAM_INTERNAL_BLOCKED: '
            '${message == null || message.isEmpty ? 'Akun Team Internal tidak memiliki akses untuk masuk ke aplikasi.' : message}',
          );
        }
        // Try to extract message from meta
        final meta = responseData['meta'];
        if (meta != null && meta is Map<String, dynamic>) {
          final metaMessage = meta['message'];
          final errorCode = meta['code']?.toString();
          if (errorCode == 'ERR_ROLE_TEAM_INTERNAL_BLOCKED') {
            final message = metaMessage?.toString().trim();
            final accessMessage = message == null || message.isEmpty
                ? 'Akun Team Internal tidak memiliki akses untuk masuk ke aplikasi.'
                : message;
            return ServerFailure('$errorCode: $accessMessage');
          }
          if (metaMessage != null && metaMessage.toString().isNotEmpty) {
            String errorMessage = metaMessage.toString();

            final data = responseData['data'];
            if (data is Map<String, dynamic>) {
              if (data.containsKey('login_attempt')) {
                errorMessage += ' login_attempt: ${data['login_attempt']}';
              }
              if (data.containsKey('lock')) {
                errorMessage += ' lock: ${data['lock']}';
              }
              if (data.containsKey('count_down')) {
                errorMessage += ' count_down: ${data['count_down']}';
              }
              if (data.containsKey('attempt_left')) {
                errorMessage += ' Sisa percobaan: ${data['attempt_left']}';
              }
            } else if (data is String && data.isNotEmpty) {
              errorMessage += ': $data';
            } else if (data is List && data.isNotEmpty) {
              errorMessage += ': ${data.join(', ')}';
            }

            return ServerFailure(errorMessage);
          }
        }

        // Try to extract from errors array (422 validation errors)
        final errors = responseData['errors'];
        if (errors != null && errors is List && errors.isNotEmpty) {
          return ServerFailure(errors.first.toString());
        }
      }

      // Fallback for status codes without parseable body
      if (statusCode >= 500) {
        return const ServerFailure('Server Error');
      }
      return ServerFailure('Request failed with status: $statusCode');
    }

    // Fallback
    return UnknownFailure(e.message ?? 'Unknown error occurred');
  }

  Future<Either<Failure, T>> executeEitherPref<T>(
      Future<T> Function() f) async {
    return executeEither(f);
  }
}
