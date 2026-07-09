import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/invoice_detail_model.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';

import '../../../common/failure.dart';

class GetInvoiceDetailUseCase {
  final InvoiceRepository _repository;

  const GetInvoiceDetailUseCase(this._repository);

  Future<Either<Failure, InvoiceDetailModel>> execute(String invoiceCode) {
    return _repository.getInvoiceDetail(invoiceCode);
  }
}
