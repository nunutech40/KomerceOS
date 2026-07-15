import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/models/meta_response.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/repositories/expire_invoice_repository.dart';
import '../datasources/remote/expire_invoice_remote_datasource.dart';

class ExpireInvoiceRepositoryImpl extends BaseRepository implements ExpireInvoiceRepository {
  final ExpireInvoiceRemoteDataSource remoteDataSource;

  ExpireInvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MetaResponse>> expireInvoice(String id) async {
    return executeEither<MetaResponse>(() async {
      final response = await remoteDataSource.expireInvoice(id);
      return response;
    });
  }
}
