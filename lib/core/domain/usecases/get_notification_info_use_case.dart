import 'package:dartz/dartz.dart';
import '../../../../common/failure.dart';
import '../entities/notification_info_model.dart';
import '../repositories/notification_v2_repository.dart';

class GetNotificationInfoUseCase {
  final NotificationV2Repository repository;

  GetNotificationInfoUseCase(this.repository);

  Future<Either<Failure, NotificationInfoModel>> call() {
    return repository.getNotificationInfo();
  }
}
