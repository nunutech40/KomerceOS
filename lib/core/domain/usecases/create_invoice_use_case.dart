import 'package:dartz/dartz.dart';

import '../../../../common/failure.dart';
import '../../data/repositories/create_invoice_repository.dart';
import '../entities/create_invoice_model.dart';

class CreateInvoiceUseCase {
  final CreateInvoiceRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Either<Failure, CreateInvoiceModel>> call({
    required String description,
    required int amount,
    required int invoiceDuration,
  }) {
    return repository.createInvoice(
      description: description,
      amount: amount,
      invoiceDuration: invoiceDuration,
    );
  }
}
