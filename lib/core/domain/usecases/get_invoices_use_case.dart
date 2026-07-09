import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/entities/invoices_model.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';

import '../../../common/failure.dart';

class GetInvoiceUseCase {
  final InvoiceRepository _repository;

  const GetInvoiceUseCase(this._repository);

  Future<Either<Failure, List<InvoicesDataModel>>> execute(
      String? type, int offset, int limit) {
    return _repository.getInvoices(type, offset, limit);
  }
}
