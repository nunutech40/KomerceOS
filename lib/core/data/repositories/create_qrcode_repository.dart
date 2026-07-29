import 'package:dartz/dartz.dart';
import '../../domain/entities/create_qrcode_model.dart';
import '../../../common/failure.dart';
import '../datasources/remote/create_qrcode_remote_datasource.dart';
import '../../../common/exception.dart';

abstract class CreateQrcodeRepository {
  Future<Either<Failure, CreateQrcodeModel>> createQrcode({
    required String channelPay,
    required String description,
    required int amount,
    required int duration,
  });
}

class CreateQrcodeRepositoryImpl implements CreateQrcodeRepository {
  final CreateQrcodeRemoteDataSource remoteDataSource;

  CreateQrcodeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CreateQrcodeModel>> createQrcode({
    required String channelPay,
    required String description,
    required int amount,
    required int duration,
  }) async {
    try {
      final response = await remoteDataSource.createQrcode(
        channelPay: channelPay,
        description: description,
        amount: amount,
        duration: duration,
      );
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
