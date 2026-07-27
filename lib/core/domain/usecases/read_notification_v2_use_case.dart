import 'package:dartz/dartz.dart';
import '../../../../common/failure.dart';
import '../repositories/notification_v2_repository.dart';

class ReadNotificationV2UseCase {
  final NotificationV2Repository repository;

  ReadNotificationV2UseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.readNotification(id);
  }
}
