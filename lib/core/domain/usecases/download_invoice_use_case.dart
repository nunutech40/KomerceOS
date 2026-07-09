import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/domain/repositories/invoice_repository.dart';

import '../../../common/failure.dart';

class DownloadInvoiceUseCase {
  final InvoiceRepository _repository;

  const DownloadInvoiceUseCase(this._repository);

  Future<Either<Failure, Uint8List>> execute(String invoiceCode) {
    return _repository.downloadInvoice(invoiceCode);
  }
}
