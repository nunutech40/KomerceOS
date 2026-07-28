import '../../models/create_invoice_response.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class CreateInvoiceRemoteDataSource {
  Future<CreateInvoiceResponse> createInvoice({
    required String description,
    required int amount,
    required int invoiceDuration,
  });
}

class CreateInvoiceRemoteDataSourceImpl
    implements CreateInvoiceRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  CreateInvoiceRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<CreateInvoiceResponse> createInvoice({
    required String description,
    required int amount,
    required int invoiceDuration,
  }) async {
    final data = {
      "description": description,
      "amount": amount,
      "invoice_duration": invoiceDuration,
    };

    final response = await client.post(
      Endpoints.createInvoice,
      data: data,
    );

    return responseParser.parseResponse<CreateInvoiceResponse>(
      response,
      (json) => CreateInvoiceResponse.fromJson(json),
    );
  }
}
