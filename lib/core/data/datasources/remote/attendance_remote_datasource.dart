import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/models/attendance_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceResponse>> getAttendance(
      int offset, int limit, String name, String startDate, String endDate);
  Future<List<AttendanceFailResponse>> getAttendanceFail(
      int offset, int limit, String name, String startDate, String endDate);
  Future<List<AttendanceAbsenceResponse>> getAttendanceAbsense(
      String name, String startDate, String endDate);
  Future<Uint8List> downloadAttendance(String startDate, String endDate);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  AttendanceRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<AttendanceResponse>> getAttendance(int offset, int limit,
      String name, String startDate, String endDate) async {
    final queryParams = {
      'offset': offset,
      'limit': limit,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await client.get(
      Endpoints.listAttendance,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<AttendanceResponse>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => AttendanceResponse.fromJson(item))
            .toList());
  }

  @override
  Future<List<AttendanceFailResponse>> getAttendanceFail(int offset, int limit,
      String name, String startDate, String endDate) async {
    final queryParams = {
      'offset': offset,
      'limit': limit,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await client.get(
      Endpoints.listAttendanceFail,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<AttendanceFailResponse>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => AttendanceFailResponse.fromJson(item))
            .toList());
  }

  @override
  Future<List<AttendanceAbsenceResponse>> getAttendanceAbsense(
      String name, String startDate, String endDate) async {
    final queryParams = {
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await client.get(
      Endpoints.listAttendanceAbsence,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<AttendanceAbsenceResponse>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => AttendanceAbsenceResponse.fromJson(item))
            .toList());
  }

  @override
  Future<Uint8List> downloadAttendance(String startDate, String endDate) async {
    final queryParams = {
      'start_date': startDate,
      'end_date': endDate,
    };

    final response = await client.get(
      Endpoints.attendanceDownload,
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );

    // Dio returns the bytes directly in data for ResponseType.bytes
    return response.data;
  }
}
