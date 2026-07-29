import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/models/meta_response.dart';

abstract class ExpireInvoiceRepository {
  Future<Either<Failure, MetaResponse>> expireInvoice(String id);
}
