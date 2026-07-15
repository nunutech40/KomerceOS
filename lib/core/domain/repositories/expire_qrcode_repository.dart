import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';

abstract class ExpireQrcodeRepository {
  Future<Either<Failure, void>> expireQrcode(String id);
}
