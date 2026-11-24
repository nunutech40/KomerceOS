import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/datasources/remote/komship_partner_id_resolver.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/data/models/kompay_mutation_response.dart';
import 'package:komtim_partner/features/superapp/features/withdrawal/domain/entities/kompay_mutation.dart';

abstract class KompayMutationRemoteDataSource {
  Future<KompayMutationResult> getMutations({
    required int page,
    int limit = 20,
    String? filter,
    String? search,
  });
}

class KompayMutationRemoteDataSourceImpl
    implements KompayMutationRemoteDataSource {
  KompayMutationRemoteDataSourceImpl({
    required this.client,
    required this.partnerIdResolver,
  });

  final DioClient client;
  final KomshipPartnerIdResolver partnerIdResolver;

  @override
  Future<KompayMutationResult> getMutations({
    required int page,
    int limit = 20,
    String? filter,
    String? search,
  }) async {
    final partnerId = await partnerIdResolver.resolve();
    final response = await client.get(
      Endpoints.komshipTransactionBalance,
      queryParameters: {
        'partner_id': partnerId,
        'page': page,
        // Komship web uses `limits`; `limit` is ignored by the API.
        'limits': limit,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return KompayMutationResponse.parsePage(response.data);
  }
}
