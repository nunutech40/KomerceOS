import 'package:dartz/dartz.dart';
import '../../../common/failure.dart';
import '../entities/check_qrcode_model.dart';
import '../../data/repositories/check_qrcode_repository.dart';

class CheckQrcodeUseCase {
  final CheckQrcodeRepository repository;

  CheckQrcodeUseCase(this.repository);

  Future<Either<Failure, CheckQrcodeModel>> execute(String id) {
    return repository.checkQrcode(id);
  }
}
