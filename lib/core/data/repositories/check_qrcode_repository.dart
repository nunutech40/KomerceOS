import 'package:dartz/dartz.dart';
import '../../domain/entities/check_qrcode_model.dart';
import '../../../common/failure.dart';
import '../datasources/remote/check_qrcode_remote_datasource.dart';
import '../../../common/exception.dart';

abstract class CheckQrcodeRepository {
  Future<Either<Failure, CheckQrcodeModel>> checkQrcode(String id);
}

class CheckQrcodeRepositoryImpl implements CheckQrcodeRepository {
  final CheckQrcodeRemoteDataSource remoteDataSource;

  CheckQrcodeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckQrcodeModel>> checkQrcode(String id) async {
    try {
      final response = await remoteDataSource.checkQrcode(id);
      return Right(response.data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
