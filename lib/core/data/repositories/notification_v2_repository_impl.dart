import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/entities/notification_v2_model.dart';
import 'package:komtim_partner/core/domain/entities/notification_info_model.dart';
import '../../domain/repositories/notification_v2_repository.dart';
import '../datasources/remote/notification_v2_remote_datasource.dart';

class NotificationV2RepositoryImpl extends BaseRepository implements NotificationV2Repository {
  final NotificationV2RemoteDataSource remoteDataSource;

  NotificationV2RepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationV2GroupModel>>> getNotifications(
    int offset,
    int limit,
    String status,
    String service,
  ) async {
    return executeEither<List<NotificationV2GroupModel>>(() async {
      final response = await remoteDataSource.getNotifications(offset, limit, status, service);
      return response.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, NotificationInfoModel>> getNotificationInfo() async {
    return executeEither<NotificationInfoModel>(() async {
      final response = await remoteDataSource.getNotificationInfo();
      return response.toEntity();
    });
  }

  @override
  Future<Either<Failure, bool>> readNotification(int id) async {
    return executeEither<bool>(() async {
      final response = await remoteDataSource.readNotification(id);
      return response.status?.toLowerCase() == 'success';
    });
  }
}
