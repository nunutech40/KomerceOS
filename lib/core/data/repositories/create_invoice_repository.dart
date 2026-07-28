import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/create_invoice_model.dart';

import '../../../../common/failure.dart';
import '../datasources/remote/create_invoice_remote_datasource.dart';
import 'base_repository.dart';

abstract class CreateInvoiceRepository {
  Future<Either<Failure, CreateInvoiceModel>> createInvoice({
    required String description,
    required int amount,
    required int invoiceDuration,
  });
}

class CreateInvoiceRepositoryImpl extends BaseRepository
    implements CreateInvoiceRepository {
  final CreateInvoiceRemoteDataSource remoteDataSource;

  CreateInvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CreateInvoiceModel>> createInvoice({
    required String description,
    required int amount,
    required int invoiceDuration,
  }) async {
    return executeEither<CreateInvoiceModel>(() async {
      final response = await remoteDataSource.createInvoice(
        description: description,
        amount: amount,
        invoiceDuration: invoiceDuration,
      );
      return response.toEntity();
    });
  }
}
