import 'package:dartz/dartz.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/core/data/repositories/base_repository.dart';
import 'package:komtim_partner/core/domain/repositories/expire_qrcode_repository.dart';
import '../datasources/remote/expire_qrcode_remote_datasource.dart';

class ExpireQrcodeRepositoryImpl extends BaseRepository implements ExpireQrcodeRepository {
  final ExpireQrcodeRemoteDataSource remoteDataSource;

  ExpireQrcodeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> expireQrcode(String id) async {
    return executeEither<void>(() async {
      await remoteDataSource.expireQrcode(id);
    });
  }
}
