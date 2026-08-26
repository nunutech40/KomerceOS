import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/apiservice/dio_response_parser.dart';
import 'package:komtim_partner/core/data/models/business_sector_response.dart';

abstract class BusinessSectorRemoteDataSource {
  Future<List<BusinessSectorResponse>> getBusinessSectors();
}

class BusinessSectorRemoteDataSourceImpl
    implements BusinessSectorRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  BusinessSectorRemoteDataSourceImpl({
    required this.client,
    required this.responseParser,
  });

  @override
  Future<List<BusinessSectorResponse>> getBusinessSectors() async {
    final response = await client.get(Endpoints.businessSector);

    return responseParser.parseResponse<List<BusinessSectorResponse>>(
      response,
      (json) => ((json as List?) ?? [])
          .map((item) => BusinessSectorResponse.fromJson(item))
          .toList(),
    );
  }
}
