import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/models/invoice_detail_response.dart';
import 'package:komtim_partner/core/data/models/invoices_response.dart';

import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class InvoiceRemoteDataSource {
  Future<List<InvoicesResponseData>> getDataInvoices(
      String? type, int offset, int limit);
  Future<InvoiceDetailResponse> getInvoiceDetail(String invoiceCode);
  Future<Uint8List> downLoadInvoice(String invoiceCode);
  Future<CheckEvaluationResponse> checkTalentEvaluation(String invoiceCode);
}

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  InvoiceRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<List<InvoicesResponseData>> getDataInvoices(
      String? type, int offset, int limit) async {
    final queryParams = {
      'offset': offset,
      'limit': limit,
      'type': type,
    };

    final response = await client.get(
      Endpoints.invoices,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<List<InvoicesResponseData>>(
        response,
        (json) => ((json as List?) ?? [])
            .map((item) => InvoicesResponseData.fromJson(item))
            .toList());
  }

  @override
  Future<InvoiceDetailResponse> getInvoiceDetail(String invoiceCode) async {
    final queryParams = {
      'invoice_code': invoiceCode,
    };

    final response = await client.get(
      Endpoints.invoiceDetail,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<InvoiceDetailResponse>(
        response, (json) => InvoiceDetailResponse.fromJson(json));
  }

  @override
  Future<Uint8List> downLoadInvoice(String invoiceCode) async {
    final queryParams = {
      'invoice_code': invoiceCode,
    };

    final response = await client.get(
      Endpoints.invoiceDownload,
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );

    // Dio handles success status codes, throws on error naturally
    return response.data;
  }

  @override
  Future<CheckEvaluationResponse> checkTalentEvaluation(String id) async {
    final queryParams = {
      'invoice_id': id,
    };

    final response = await client.get(
      Endpoints.checkEvaluation,
      queryParameters: queryParams,
    );

    return responseParser.parseResponse<CheckEvaluationResponse>(
        response, (json) => CheckEvaluationResponse.fromJson(json));
  }
}
