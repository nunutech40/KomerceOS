import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/domain/repositories/expire_qrcode_repository.dart';

class ExpireQrcodeUseCase {
  final ExpireQrcodeRepository repository;

  ExpireQrcodeUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.expireQrcode(id);
  }
}
