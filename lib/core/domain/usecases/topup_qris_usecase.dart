import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/topup_qris_response.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';

import '../../../common/failure.dart';

class TopUpQrisUseCase {
  final TopUpRepository repository;
  // final GetProfileUseCase getProfileUseCase;
  TopUpQrisUseCase(
    this.repository,
    //  this.getProfileUseCase
  );

  Future<Either<Failure, TopupQRISResponse>> execute(String nominal) async {
    final dataTopUpQris = await repository.topUpQris(nominal);
    return dataTopUpQris;
  }
}
