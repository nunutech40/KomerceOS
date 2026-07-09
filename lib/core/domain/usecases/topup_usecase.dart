import 'package:dartz/dartz.dart';
import 'package:komtim_partner/core/data/models/topup_response.dart';
import 'package:komtim_partner/core/domain/repositories/top_up_repository.dart';

import '../../../common/failure.dart';

class TopUpUseCase {
  final TopUpRepository repository;
  // final GetProfileUseCase getProfileUseCase;
  TopUpUseCase(
    this.repository,
    //  this.getProfileUseCase
  );

  Future<Either<Failure, TopupResponse>> execute(
      String nominal, int adminFee) async {
    final dataTopUpBank = await repository.topUpBank(nominal, adminFee);
    // await getProfileUseCase.execute();
    return dataTopUpBank;
  }
}
