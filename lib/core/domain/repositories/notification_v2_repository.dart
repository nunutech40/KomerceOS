import 'package:dartz/dartz.dart';
import '../entities/notification_info_model.dart';
import '../../../../common/failure.dart';
import '../entities/notification_v2_model.dart';

abstract class NotificationV2Repository {
  Future<Either<Failure, List<NotificationV2GroupModel>>> getNotifications(
    int offset,
    int limit,
    String status,
    String service,
  );
  Future<Either<Failure, NotificationInfoModel>> getNotificationInfo();
}
