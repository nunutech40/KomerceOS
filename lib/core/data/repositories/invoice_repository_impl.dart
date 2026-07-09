import 'dart:typed_data';

import 'package:komtim_partner/core/data/datasources/remote/invoice_remote_datasource.dart';
import 'package:komtim_partner/core/data/models/invoice_detail_response.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';

import '../../../common/failure.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'base_repository.dart';

import 'package:dartz/dartz.dart';

class InvoiceRepositoryImpl extends BaseRepository
    implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<InvoicesDataModel>>> getInvoices(
      String? type, int offset, int limit) async {
    return executeEither(() async {
      final result =
          await remoteDataSource.getDataInvoices(type, offset, limit);
      final invoiceData = result.map((item) => item.toEntity()).toList();
      return invoiceData;
    });
  }

  @override
  Future<Either<Failure, InvoiceDetailModel>> getInvoiceDetail(
      String invoiceCode) async {
    return executeEither(() async {
      final result = await remoteDataSource.getInvoiceDetail(invoiceCode);
      final invoiceDetailModel = result.toEntity();
      return invoiceDetailModel;
    });
  }

  @override
  Future<Either<Failure, Uint8List>> downloadInvoice(String invoiceCode) async {
    return executeEither(() async {
      final result = await remoteDataSource.downLoadInvoice(invoiceCode);
      return result;
    });
  }

  @override
  Future<Either<Failure, CheckEvaluationResponse>> checkTalentsEvaluation(
      String id) {
    return executeEither(() async {
      final result = await remoteDataSource.checkTalentEvaluation(id);
      final invoiceDetailModel = result.toEntity();
      return invoiceDetailModel;
    });
  }
}
