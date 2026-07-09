import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/invoice_detail_response.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import '../../../common/failure.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, List<InvoicesDataModel>>> getInvoices(
      String? type, int offset, int limit);
  Future<Either<Failure, InvoiceDetailModel>> getInvoiceDetail(
      String invoiceCode);
  Future<Either<Failure, Uint8List>> downloadInvoice(String invoiceCode);
  Future<Either<Failure, CheckEvaluationResponse>> checkTalentsEvaluation(
      String id);
}
