import 'package:dartz/dartz.dart';
import '../../../../common/failure.dart';
import '../entities/notification_v2_model.dart';
import '../repositories/notification_v2_repository.dart';

class GetNotificationV2ListUseCase {
  final NotificationV2Repository repository;

  GetNotificationV2ListUseCase(this.repository);

  Future<Either<Failure, List<NotificationV2GroupModel>>> call(
    int offset,
    int limit,
    String status,
    String service,
  ) {
    return repository.getNotifications(offset, limit, status, service);
  }
}
