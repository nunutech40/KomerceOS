import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';
import '../../domain/entities/check_qrcode_model.dart';
import '../../../common/failure.dart';
import '../datasources/remote/check_qrcode_remote_datasource.dart';
import '../../../common/exception.dart';

abstract class CheckQrcodeRepository {
  Future<Either<Failure, CheckQrcodeModel>> checkQrcode(String id);
}

class CheckQrcodeRepositoryImpl implements CheckQrcodeRepository {
  final CheckQrcodeRemoteDataSource remoteDataSource;
  final SuperappProfileRepositoryImpl? superappProfileRepository;

  CheckQrcodeRepositoryImpl({
    required this.remoteDataSource,
    this.superappProfileRepository,
  });

  @override
  Future<Either<Failure, CheckQrcodeModel>> checkQrcode(String id) async {
    try {
      final response = await remoteDataSource.checkQrcode(id);
      final model = response.data;

      // Trigger profile refresh saat transaksi berhasil
      // Saldo akan otomatis update tanpa perlu user pull-to-refresh
      if (model.statusPayment?.toUpperCase() == 'SUCCESS') {
        superappProfileRepository?.notifyProfileRefresh();
      }

      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
