import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/models/meta_response.dart';
import 'package:komtim_partner/core/domain/repositories/expire_invoice_repository.dart';

class ExpireInvoiceUseCase {
  final ExpireInvoiceRepository repository;

  ExpireInvoiceUseCase({required this.repository});

  Future<Either<Failure, MetaResponse>> call(String id) {
    return repository.expireInvoice(id);
  }
}
