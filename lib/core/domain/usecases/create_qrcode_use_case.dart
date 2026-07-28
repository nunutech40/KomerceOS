import 'package:dartz/dartz.dart';
import '../../data/repositories/create_qrcode_repository.dart';
import '../entities/create_qrcode_model.dart';
import '../../../common/failure.dart';

class CreateQrcodeUseCase {
  final CreateQrcodeRepository repository;

  CreateQrcodeUseCase(this.repository);

  Future<Either<Failure, CreateQrcodeModel>> execute({
    required String channelPay,
    required String description,
    required int amount,
    required int duration,
  }) {
    return repository.createQrcode(
      channelPay: channelPay,
      description: description,
      amount: amount,
      duration: duration,
    );
  }
}
