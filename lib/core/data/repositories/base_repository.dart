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
      return ConnectionFailure(
          'Failed to connect to the network: ${e.message}');
    }

    // Bad response (4xx, 5xx) — extract meta message from response body
    if (e.type == DioExceptionType.badResponse && e.response != null) {
      final responseData = e.response!.data;
      final statusCode = e.response!.statusCode ?? 0;

      if (responseData is Map<String, dynamic>) {
        // Try to extract message from meta
        final meta = responseData['meta'];
        if (meta != null && meta is Map<String, dynamic>) {
          final metaMessage = meta['message'];
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
